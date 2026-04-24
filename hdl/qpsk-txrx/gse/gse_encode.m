function [enc_msg,status] = gse_encode(msg, hmac, counter)
%GSE_ENCODE Encode message into gse packet
%   Some of the worst code ever written
arguments (Input)
    msg     (1,:)   uint8 % UTF-8 or otherwise 8 bit encoded message
    hmac    (1,1)   string = "SkubeTradeshowDemoKey"
    counter (1,1)   uint16 = 0
end

arguments (Output)
    enc_msg (1,:) uint8  % GSE Encapsulated Messaged
    status  (1,1) string % Error / Success 
end

ENCODED_FILE= "./gse/gse_output.bin";

% Cursed passing of message as UTF-8 characters no matter what they
% actually are lol
msg_str = native2unicode(msg,"UTF-8");

% ☠️☠️☠️☠️☠️
cmd_str = sprintf("./gse/GSEEncapForSkube '%s' %s %i",msg_str,hmac,counter);
[cmd_status, cmd_out] = system(cmd_str);

if cmd_status ~= 0
    status = "ERROR";
    enc_message = NaN;
    error("GSE Encap Unknown Error: %s",cmd_out)
else 
    status = "SUCCESS";
    fid = fopen(ENCODED_FILE,"r");
    enc_msg = fread(fid,"uint8");
    fclose(fid);
end

delete(ENCODED_FILE)
