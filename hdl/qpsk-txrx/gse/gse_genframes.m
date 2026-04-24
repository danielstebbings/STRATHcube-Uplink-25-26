function [gse_frames, lframe] = gse_genframes(msg, hmac, nframes)
%GSE_GENFRAMES Generation of GSE input frames using 
arguments (Input)
    msg     (1,:)   uint8 % UTF-8 or otherwise 8 bit encoded message
    hmac    (1,1)   string = "SkubeTradeshowDemoKey"
    nframes (1,1)   = 1
end

arguments (Output)
    gse_frames (:,:) uint8  % nframe*lframe  GSE Encapsulated Messages
    lframe     (1,1)    % Error / Success 
end


lframe = 41+length(msg);
gse_frames = zeros(nframes,lframe);

for n = 1:nframes
    gse_frames(n,:) = gse_encode(msg,hmac,n-1);  
end