%% Verification script for the dvbs2hdlTransmitter models.
% This script verifies the dvbs2hdlTransmitter model output with reference
% transmitter waveform generator output

disp(newline);
disp('Simulation Completed. Running verification script...')
simDummyFrameNums = simDummyFrameNos.Data(:);
s2Config = dvbs2hdlTxParameters;
RRCgain =  sum(s2Config.RRCImpulseResponse);
getdvbs2LDPCParityMatrices;
matTxWaveform = [];
matframeLen = zeros(1,nFrames);
txObj = dvbs2WaveformGenerator("StreamFormat",StreamFormat,...
                                "HasPilots",true,...
                                "FECFrame","normal");
if strcmpi(StreamFormat,"GS")
    txObj.UPL = UPL;
end
for ii = 1:nnz(simDummyFrameNums == 0)
    matTxWaveform = [matTxWaveform;txObj(zeros(0,1)).*RRCgain]; %#ok<AGROW> 
end
for frameNo = 1 : nFrames
    if FECFrame(frameNo)
        FECFrameStr = "short";
    else
        FECFrameStr = "normal";
    end
    set(txObj,"MODCOD",MODCOD(frameNo));
    set(txObj,"DFL",DFL(frameNo));
%     set(txObj,"HasPilots",true);
    set(txObj,"FECFrame",FECFrameStr);
    addpath s2xLDPCParityMatrices;
    matTxWaveform = [matTxWaveform;txObj(frameBits{frameNo}(:)).*RRCgain]; %#ok<AGROW> 
    rmpath s2xLDPCParityMatrices;
    for ii = 1:nnz(simDummyFrameNums == frameNo)
        matTxWaveform = [matTxWaveform;txObj(zeros(0,1)).*RRCgain]; %#ok<AGROW> 
    end
end

if length(matTxWaveform) > length(simTxWaveform)
    matTxWaveform = matTxWaveform(1:length(simTxWaveform));
    simTxWaveform = double(simTxWaveform);
else
    simTxWaveform = double(simTxWaveform(1:length(matTxWaveform)));
end

if length(MODCOD) ~= max(simDummyFrameNums)
    error('Frames corresponding to all the MODCOD values are not generated');
end

relativeMSE = @(a,b) 10*log10(sum(abs(a-b).^2)/sum(abs(a).^2));

err = matTxWaveform - double(simTxWaveform);
figure(1);
subplot(211);
plot(real(err),'.r-');
xlabel('Sample Count');ylabel('Amplitude');
title('Real Part of Tx Output Error');
subplot(212);
plot(imag(err),'.r-');
xlabel('Sample Count');ylabel('Amplitude');
title('Imaginary Part of Tx Output Error');
MSERe = relativeMSE(real(matTxWaveform),real(simTxWaveform));
MSEIm = relativeMSE(imag(matTxWaveform),imag(simTxWaveform));
disp(['Relative mean squared error (dB) between the simulink output and reference = Real: ' num2str(MSERe) ' Imag: ' num2str(MSEIm)]) 

%% getdvbs2LDPCParityMatrices
% This functions checks for the existence of the LDPC Matrices and
% downloads them if they doesn't exist

function getdvbs2LDPCParityMatrices()
   if ~exist('s2xLDPCParityMatrices/dvbs2xLDPCParityMatrices.mat','file')
       if ~exist('s2xLDPCParityMatrices.zip','file')
           url = 'https://ssd.mathworks.com/supportfiles/spc/satcom/DVB/s2xLDPCParityMatrices.zip';
           websave('s2xLDPCParityMatrices.zip',url);
           unzip('s2xLDPCParityMatrices.zip');
       end
   end
end