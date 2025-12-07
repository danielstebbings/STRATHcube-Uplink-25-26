function [snr, signal_power, noise_power, total_loss] = link(elevation,altitude,bandwidth,link_parameters)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    elevation   (1,:) % Satellite elevation(s) over Ground Station
    altitude    (1,:) % Satellite altitude(s) over Ground Station
    bandwidth   (1,1) = 5*1000
    %verbose     (1,1) = false
    link_parameters struct = struct( ...
                                "Frequency",            437e6, ...         % Hz
                                "GS_Altitude",          70, ...            % m  James Weir
                                "GS_EIRP",              10*log10(25), ...  % dBW
                                "Polarisation_Loss",    3, ...             % dB Linear -> Circular   
                                "Pointing_Loss",        1, ...             % dB
                                "Sat_Ant_Gain",         0, ...             % dB ISIS Antenna
                                "Sat_Losses",           1.26, ...          % dB Matching+Switch+Cable+Connector
                                "Sat_LNA_Gain",         19, ...            % dB TOTEM FrontendUHF
                                "Sat_LNA_NF",           1.60, ...          % dB TOTEM FrontendUHF (Nominal, 1.28 low, 1.92 high)
                                "Sat_SDR_S11_Loss",     1.44, ...          % dB TOTEM Motherboard, S11=-5.5dB
                                "Sat_SDR_NF",           2.5, ...           % dB AD9364 Datasheet
                                "T_Galactic",           29, ...            % K  ITU-R P.372-13
                                "T_Manmade",            2900 ...           % K  ITU-R P.372-13
                                );
end

arguments (Output)
    snr
    signal_power
    noise_power
    total_loss
end
    % Atmospheric Absorption Values
    persistent atmoatt
    if isempty(atmoatt)
        atmoatt = load("Atmospheric_Attenuation.mat","Atmospheric_Attenuation").Atmospheric_Attenuation;        
    end
    atmoatt_minelev = min(atmoatt.Angle_deg);
    atmoatt_delev   = atmoatt(2,:).Angle_deg - atmoatt(1,:).Angle_deg;

    % Atmospheric losses
    APL = zeros(1,length(elevation));
    for elevation_it = 1:length(elevation)
        norm_elev = elevation(elevation_it);
        if (norm_elev > 90) 
            norm_elev = 180 - norm_elev;
        end
        if (norm_elev < atmoatt_minelev)
            norm_elev = atmoatt_minelev;
        end
        norm_elev = round(norm_elev/atmoatt_delev)*atmoatt_delev;

        APL(elevation_it) = atmoatt(find(atmoatt.Angle_deg==norm_elev,1),:).Total_dB;
    end
    
    slant_ranges = zeros(1,length(altitude));
    for slant_it = 1:length(altitude)
        slant_ranges(slant_it) =  slantRangeCircularOrbit(elevation(slant_it),  ...
                                                          altitude(slant_it),   ...
                                                          link_parameters.GS_Altitude ...
                                                          );
    end
    free_space_path_loss = 20*log10(4*pi*slant_ranges*link_parameters.Frequency/299792458); % dB

    signal_power = link_parameters.GS_EIRP ...
                    - free_space_path_loss ...
                    - APL ...
                    - link_parameters.Pointing_Loss ...
                    - link_parameters.Polarisation_Loss ...
                    + link_parameters.Sat_Ant_Gain ...
                    - link_parameters.Sat_Losses ...
                    + link_parameters.Sat_LNA_Gain ...
                    - link_parameters.Sat_SDR_S11_Loss;

    boltz_noise = 10*log10(1.38e-23 * 290 * bandwidth);
    % ITU P.372-13 Figure 3
    T_Ref       = 290; % K
    galactic_NF = 10*log10(link_parameters.T_Galactic/T_Ref + 1);
    manmade_NF  = 10*log10(link_parameters.T_Manmade/T_Ref + 1);

    noise_power = boltz_noise ...
                   + galactic_NF ...
                   + manmade_NF ...
                   + link_parameters.Sat_Ant_Gain ...
                   - link_parameters.Sat_Losses ...
                   + link_parameters.Sat_LNA_Gain ...
                   + link_parameters.Sat_LNA_NF ...
                   - link_parameters.Sat_SDR_S11_Loss ...
                   + link_parameters.Sat_SDR_NF;
    
    snr = signal_power - noise_power;

    total_loss = free_space_path_loss ...
                  - APL ...
                  + link_parameters.Sat_Ant_Gain ...
                  - link_parameters.Sat_Losses ...
                  + link_parameters.Sat_LNA_Gain ...
                  - link_parameters.Sat_SDR_S11_Loss;

                    

end