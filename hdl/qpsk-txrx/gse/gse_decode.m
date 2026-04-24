function [dec_msg, status] = gse_decode(enc_msg, hmac, verbose)
%gse_decode use kyle's gse decoder function to decode message
%   Detailed explanation goes here

arguments (Input)
    enc_msg (1,:) uint8
    hmac    (1,1) string = "SkubeTradeshowDemoKey"
    verbose (1,1) logical = false
end

arguments (Output)
    dec_msg (1,:) uint8
    status  (1,1) string
end

ENCODED_FILE= "./gse/gse_output.bin";
DECODED_FILE= "./gse/payload_recovered.bin";

% Write message to binary file

fid = fopen(ENCODED_FILE,'w');
fwrite(fid,enc_msg,'uint8');
fclose(fid);

% Call decap function and print results
cmd_str = sprintf("./gse/GSEDeencapForSkube '%s'",hmac);
[cmd_status, cmd_out] = system(cmd_str);

if cmd_status ~= 0
    % Error occured 
    if contains(cmd_out, "Packet discarded due to HMAC mismatch")
        status = "HMAC_ERROR"
    elseif contains(cmd_out, "Failed to open input file")
        status = "FILE_ERROR"
        error(sprintf("Decap File Read Error: %s", cmd_out));
    else
        status = "ERROR";
        error(sprintf("Decap Unknown Error: %s", cmd_out));
    end
    dec_msg = NaN;
else

fid = fopen(DECODED_FILE,"r");
dec_msg = fread(fid,"uint8");
status = "SUCCESS";
fclose(fid);

if(verbose)
    cmd_out
    cmd_status
end

end
