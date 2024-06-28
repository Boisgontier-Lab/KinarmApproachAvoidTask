function l=flength(fid)
%flength() DO NOT USE
%
% Used to determine the length of a file that is being read
  cur_pos = ftell(fid);
  fseek(fid, 0, 'eof');
  l = ftell(fid);
  fseek(fid, cur_pos, 'bof');
end