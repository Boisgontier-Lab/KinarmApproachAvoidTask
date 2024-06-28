function [ st ] = freadstring( fid )
%freadstring() DO NOT USE
%
% Used when falling back to the vanilla file reader.
    str_size = flength(fid);
    st = char(fread(fid, str_size, 'char')');
end

