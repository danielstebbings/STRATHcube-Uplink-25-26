function [encoded] = dvbs2_fecencode(message)
%DVBS2_FECENCODE Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    message (:,1) int8 
end

arguments (Output)
    encoded int8
end

if ~exist('dvbs2xLDPCParityMatrices.mat','file')
    if ~exist('s2xLDPCParityMatrices.zip','file')
        url = 'https://ssd.mathworks.com/supportfiles/spc/satcom/DVB/s2xLDPCParityMatrices.zip';
        websave('s2xLDPCParityMatrices.zip',url);
        unzip('s2xLDPCParityMatrices.zip');
    end
addpath('s2xLDPCParityMatrices');
end

FECFRAMELENGTH = 16200; % Short FECFRAME
DATALENGTH = 3072;
RATE = '1/4';

bchenc = satcom.internal.dvbs.bchEncode(message,DATALENGTH,16200);
encoded = satcom.internal.dvbs.ldpcEncode(bchenc,RATE,16200);



