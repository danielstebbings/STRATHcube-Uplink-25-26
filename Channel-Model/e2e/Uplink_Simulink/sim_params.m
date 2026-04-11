%[text] # Sim Parameters
%[text] Setup workspace based on block mask settings
%[text] Detailed explanation of this function.
function sim_params( ...
            bitRate, bitsPerSymbol, ...
            selDoppler, altitude, frequency, gain, ...
            tx_rrcSamplesPerSymbol, tx_rrcSpan,tx_selLvlBO, ...
            rx_rrcSamplesPerSymbol, rx_rrcSpan, rx_temp, rx_ADCbits ...
            )
arguments (Input)
    bitRate
    bitsPerSymbol
    selDoppler
    altitude
    frequency
    gain                (2,1)

    tx_rrcSamplesPerSymbol
    tx_rrcSpan
    tx_selLvlBO

    rx_rrcSamplesPerSymbol
    rx_rrcSpan
    rx_temp
    rx_ADCbits    
end


% Convert bitrate to a nice number
tx_params.Rb  = bitRate - mod(bitRate,2^bitsPerSymbol);
tx_params.bitsPerSymbol = bitsPerSymbol;
tx_params.Rs = tx_params.Rb / 2^tx_params.bitsPerSymbol;

tx_params.sourceSamplesPerFrame = 400 - mod(400,tx_params.Rb);
tx_params.sourceFrameTime = 1/(tx_params.Rb/tx_params.sourceSamplesPerFrame);
tx_params.rrcSamplesPerSymbol = rrcSamplesPerSymbol;

[tx_params.GindB,tx_params.GoutdB] = updateHPA(selLvlBO);

link_params.altitude  = altitude;
link_params.frequency = frequency;

% Icon code change on RX Thermal Noise block
rx_params.RXTemp = rx_temp;

tx_params.AntGain  = gain(1);
rx_params.AntGain  = gain(2);

rx_params.ADC_NumBits = rx_ADCbits;

% Imbalances: Amp, Phase, I DC Off, Q DC Off
% AD9364 Datasheet @ 800MHz
tmp = [0.01 0.2 1e-8 5e-8]; 
rx_params.IQImbal = zeros(1,4);
if selImbal ~= 1
    rx_params.IQImbal = tmp;
end
    


% Send parameter structs to base workspace
assignin('base', 'tx_params',   tx_params);
assignin('base', 'rx_params',   rx_params);
assignin('base', 'link_params', link_params);
end


%*********************************************************************
% Function Name:     updateHPA
% Description:       update nonlinear amplifier input and output gains      
%********************************************************************
function [GindB, GoutdB] = updateHPA(selLvlBO)

    % Update the saturation level parameters
    valsBO = [-30 -7 -1];       % values for backoff
    rrcComp = 20*log10(.38);    % compensation for RRC filter P2P power
    gainLin = 18;               % fixed HPA linear gain
    alpha = 20*log10(2.1587);   % difference between linear gain and
                                % small signal gain
    sps = 8;                    % Sample per symbol
    rctGain = 10*log10(sps);    % Raised Cosine Filter Gain
    
    gainIP = valsBO - rrcComp - rctGain;
    GindB = gainIP(selLvlBO);
    gainOP = -valsBO + rrcComp - alpha + gainLin;
    GoutdB = gainOP(selLvlBO);
end
% EOF

%[appendix]{"version":"1.0"}
%---
