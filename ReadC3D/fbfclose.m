function fbfclose( fid )
%FBFCLOSE DO NOT USE 
%
%Used to close files that are being read by these scripts.


    try
        fclose(fid);
    catch ex
    end

end

