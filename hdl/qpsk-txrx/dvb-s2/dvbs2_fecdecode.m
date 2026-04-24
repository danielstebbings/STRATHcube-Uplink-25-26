function [decoded] = dvbs2_fecdecode(encoded)
%DVBS2_FECDECODE Decode Frames
%   Detailed explanation goes here
arguments (Input)
    encoded
end

arguments (Output)
    decoded
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

nIter = 10;
parallelism = 45;
ldpcDecLat = nIter*6500;

ldpcLen = length(encoded);   
encFrameGap = cwLen + ldpcDecLat + 2000;



end