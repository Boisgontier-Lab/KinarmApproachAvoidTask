function do_fallback = fbdetect( )
%fbdetect() - An internal method the detects if optimized file loading can 
% be used or not.
%
% Optimized file loading makes use of mex'd C code and various other
% advanced MATLAB features like Java integration. This should always work 
% on Windows. On some systems, like Mac the mex'd code throws up warnings 
% to the operator about running unsigned code. For Mac and linux you can
% try to mex the C code in @mfile yourself (ex. mex fread.c), then set the
% global variable described below to false.
%
% If you are having trouble on Windows using the optimized code then set a
% global variable as:
% 
% global kinarm_reading_fallback
% kinarm_reading_fallback = true;
%
% This will force using the non-optimized, vanilla MATLAB code to read data
% files.
    global kinarm_reading_fallback
    persistent should_fallback
    
    if ~isempty(kinarm_reading_fallback)
        do_fallback = kinarm_reading_fallback;
        if do_fallback
            fprintf('\nGlobal variable kinarm_reading_fallback is set to use fallback exam reader');
        else
            fprintf('\nGlobal variable kinarm_reading_fallback is set to use standard exam reader');
        end
        return
    end

    if isempty(should_fallback)
        
            
        if ispc()
            try
                % try to use all mex functions that could fail
                fid = mfile(zeros(10, 1, 'uint8'));
                flength(fid);
                fread(fid, 1, '*float32');
                fread_int(fid, 1, false);
                fseek(fid, 0, 'bof');
                ftell(fid);
                should_fallback = false;
            catch ME
                should_fallback = true;
                fprintf('\nWarning: Using non-optimized file loading.\n')
            end
        else
            should_fallback = true;
        end
            
    end

    do_fallback = should_fallback;

end

