function [ out_int ] = fread_int( fid, count, ignore )
%FREAD_INT DO NOT USE
%
% Used when falling back to the vanilla file reader.

    out_int = fread(fid, count, '*uint32');

end

