%% Initialization script for the dvbs2hdlTransmitter models.
% This script generates the model initialization parameters for the
% dvbs2hdlTransmitter model

Rsym = eval(get_param('dvbs2hdlTransmitter/Input Configuration','Rsym'));
StreamFormat = get_param('dvbs2hdlTransmitter/Input Configuration','InputStreamFormat');
UPL = eval(get_param('dvbs2hdlTransmitter/Input Configuration','UPLval'));

MODCOD = eval(get_param('dvbs2hdlTransmitter/Input Configuration','MODCODval'));
FECFrame = eval(get_param('dvbs2hdlTransmitter/Input Configuration','FECFrameval'));

% validation
validateattributes(MODCOD,{'double'},{'finite','real','integer','row','nonempty','>=',1,'<=',28},'','MODCOD');
validateattributes(FECFrame,{'double'},{'row','binary'},'','FECFrame');
validateattributes(Rsym,{'double'},{'scalar','positive','>=',1e6,'<=',50e6},'','symbol rate');

if ~isequal(length(MODCOD),length(FECFrame))
    error('MODCOD and FECFrame must be of length');
end

if any(FECFrame(MODCOD == 11))
    error('FECFrame = 1 (short) is not supported for MODCOD = 11');
end
if any(FECFrame(MODCOD == 17))
    error('FECFrame = 1 (short) is not supported for MODCOD = 17');
end
if any(FECFrame(MODCOD == 23))
    error('FECFrame = 1 (short) is not supported for MODCOD = 23');
end
if any(FECFrame(MODCOD == 28))
    error('FECFrame = 1 (short) is not supported for MODCOD = 28');
end

[DFL,PLFL]           = getMaxDFL(MODCOD,FECFrame);

DFLNormal = getMaxDFL(1:28,zeros(1,28));
DFLShort = [getMaxDFL(1:10,ones(1,10)) 0 getMaxDFL(12:16,ones(1,5)) 0 getMaxDFL(18:22,ones(1,5)) 0 getMaxDFL(24:27,ones(1,4)) 0];

validateattributes(UPL,{'double'},{'nonempty','finite','scalar','integer','>=',0,'<=',min(DFL(:))-10});

if strcmpi(StreamFormat,'GS')
    if UPL == 0
        TSorGS = 1;
    else
        TSorGS = 0;
    end
    [frameBits,pktsSent,syncWord]      = generateUserPkts(StreamFormat,DFL,UPL);
else
    TSorGS = 3;
    UPL = 1504;   % overwrite UPL value for TS format
    [frameBits,pktsSent,syncWord]      = generateUserPkts(StreamFormat,DFL);
end

nFrames = length(DFL);
bitsIn = logical([]);
for frameNo = 1:nFrames
    bitsIn = [bitsIn;reshape(logical(frameBits{frameNo}),[],1)]; %#ok<AGROW>
end

stopTime = 1.65 * (sum(2*PLFL)/Rsym);



function [bitsInFrames,nPkts,syncWord] = generateUserPkts(StreamFormat,DFL,varargin)
% This function generates TS or GS packets for all frames
   if strcmpi(StreamFormat,'TS')
       UPL      = 188*8;
       syncWord = [0;1;0;0;0;1;1;1];  % 47 HEX
       cont     = false;
   else
       UPL = varargin{1};
       if UPL ~= 0 
           syncWord = zeros(8,1);%randsrc(8,1,[0,1]);
           cont     = false;
       else                           % continuous GS streams
           syncWord = 0;
           cont     = true;
       end
   end
   nFrames = length(DFL);
   bitsInFrames = cell(1,nFrames);
   if cont
       for i = 1 : nFrames
           bitsInFrames{i}    = randsrc(DFL(i),1,[0,1]);
       end
       nPkts = 0;
   else
       packetsInFrames       = floor(double(DFL)/double(UPL));
       bitsInFrames = cell(1,nFrames);
       for i = 1 : nFrames
           bitsInFrames{i}    = [repmat(syncWord,1,packetsInFrames(i));randsrc(UPL-length(syncWord),packetsInFrames(i),[0,1])];
       end
       nPkts = sum(packetsInFrames);
   end
   syncWord = uint8(bin2dec(char(syncWord.'+'0')));
end

function [DFL,PLFL] = getMaxDFL(MODCOD,FECFrame)
%    if ~(isequal(size(MODCOD),size(FECFrame)) && (size(MODCOD,1) == 1))
%        error('MODCOD,FECFrame must be row vectors of same length')
%    end
   Kbch = zeros(size(MODCOD));
   for i = 1:length(MODCOD)
       if FECFrame(i)
           if any(MODCOD(i) == [11 17 23 28])
               error(['MODCOD = ' num2str(MODCOD(i)) ' is not supported for FECFrame = 1 (short)']);
           end
           [~,R,cwLen] = satcom.internal.dvbs.getS2PHYParams(MODCOD(i),'short');
       else
           [~,R,cwLen] = satcom.internal.dvbs.getS2PHYParams(MODCOD(i),'normal');
       end
       [~,Kbch(i)] = satcom.internal.dvbs.getBCHParams(cwLen,R);
   end
   DFL = Kbch - 80;
   FL(1,:) = 64800./[2*ones(1,11) 3*ones(1,17-11) 4*ones(1,23-17) 5*ones(1,28-23)];
   FL(2,:) = FL(1,:)/4;
   PLFL = diag(FL(FECFrame+1,MODCOD));
end