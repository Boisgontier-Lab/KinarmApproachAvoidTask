classdef ZipReaderFallback < handle
    %ZIP_READER This class is set up to use some standard java calls to
    %read the contents of a zip file into memory as and array of uint8. The
    %data can the be read using a memory file using standard fread, ftell
    %etc functions.
    
    properties
        bClasicFormat
        file_name
        zip_contents
        folder_map
        
        root_folder
    end
    
    methods
        function obj = ZipReaderFallback(fname)
            obj.bClasicFormat = ~isempty(strfind(fname, '.zip'));
            obj.file_name = fname;
            zc = obj.dir();          
            zip_map = containers.Map();
            
            % builds up a map of folder names to folder contents
            for n=1:length(zc)
                fname = zc{n};              
                [folder, name, ~] = fileparts(fname);
                if ~isempty(folder)                
                    if ~isKey(zip_map, folder)
                        zip_map(folder) = {};
                    end
                    if ~isempty(name)
                        arr = zip_map(folder);
                        arr{end+1} = fname;
                        zip_map(folder) = arr;
                    end
                end
            end
            obj.folder_map = zip_map;
            obj.zip_contents = zc;
        end
        
        function zip_contents=dir(obj)            
            if isempty(obj.zip_contents)                
                obj.root_folder = create_tmp_folder();
                obj.zip_contents = unzip(obj.file_name, obj.root_folder);

                for ii=1:length(obj.zip_contents)
                    name = obj.zip_contents{ii};
                    name = name(length(obj.root_folder) + 2:end);
                    obj.zip_contents{ii} = strrep(name, '\', '/');
                end
            end
            zip_contents = obj.zip_contents;
        end

        function trial_names=listTrials(obj)   
            % Find the names of all trial in the exam
            trial_names = {};
            
            if obj.bClasicFormat
                % Trials are in the raw folder and end in .c3d
                rawData = obj.folder_map('raw');
                for i=1:length(rawData)
                    name = rawData{i};
                    if ~isempty(strfind(name, '.c3d')) && isempty(strfind(name, 'common.c3d'))
                        trial_names{end+1} = name;
                    end
                end
            else
                % trials are folder in the raw folder.
                names = keys(obj.folder_map);
                for i=1:length(names)
                    name = names{i};
                    if obj.startsWith(name, 'raw') && isempty(strfind(name, 'common'))
                        trial_names{end+1} = char(name);
                    end
                end
            end
        end
        
        function bSuccess=startsWith(obj, val, find)
            bSuccess = false;
            
            if isempty(strfind(val, find))
                return
            end
            bSuccess = strfind(val, find) == 1 && length(val) ~= length(find);               
        end

        function fnames=listAnalysis(obj)                      
            % Find the names of all analysis files in the exam
            fnames = {};
            
            if obj.bClasicFormat
                if isKey(obj.folder_map, 'analysis')
                    rawData = obj.folder_map('analysis');
                    for i=1:length(rawData)
                        name = rawData{i};
                        if ~isempty(strfind(name, '.c3d'))
                            fnames{end+1} = name;
                        end
                    end
                end
            else
                names = keys(obj.folder_map);
                for i=1:length(names)
                    name = names{i};
                    if ~isempty(strfind(name, 'analysis') == 1) && ~strcmp(name, 'analysis')
                        fnames{end+1} = char(name);
                    end
                end
            end
        end
        
        function bHas = containsFile(obj, name)
            bHas = ~isempty(find(strcmp(obj.zip_contents, name),1));
        end

        function bHas = containsFolder(obj, name)
            bHas = isKey(obj.folder_map, name);
        end

        % Construct a fid that is a memory based file for reading an entry
        % in a zip file
        function fid=fopen(obj, path)                   
            fid = fopen(obj.getFullPath(path), 'r');                
        end

 
        function fpath=getFullPath(obj, path)
            fpath = [obj.root_folder, '/', path];
        end
        
        function nameMap=readFolder(obj, path)
            % For the new data structure (.kinarm files), this reads in all 
            % of the data for a single trial at once. This is much faster
            % than reading the zip entries individually.
            % This method returns a Map object that is zip entry name ->
            % file reading struct.
%             [zipFileSystem, root, doClose] = obj.getOpenFileSystem();
            
            entrynames = obj.folder_map(path);
            names{length(entrynames)} = [];
            fids{length(entrynames)} = [];
            
            for i=1:length(entrynames)
                names{i} = entrynames{i};
                fid = obj.fopen(entrynames{i});
%                 flen = flength(fid);
%                 byteData = fread(fid, flen, '*uint8');
                 byteData = fread(fid, 1, '*uint8');
                 fbfclose(fid);
                % if the version number is in the first byte then we know
                % the data is Little Endian. No version that went to
                % customers was ever Big Endian.
                bLE = byteData(1) ~= 0; 
                fids{i} = make_file_struct(obj.getFullPath(entrynames{i}), bLE);
            end
            
            nameMap = containers.Map(names, fids);  
        end
        
        function close(obj)
            % Close the open FileSystem object if it is still open.
           if exist(obj.root_folder, 'dir') == 7
               rmdir(obj.root_folder,'s')
           end
        end
    end
    
    methods (Access=private)
                
        function bb=readIntobyteBuffer(obj, path)
            [zipFileSystem, root, doClose] = obj.getOpenFileSystem();

            p = root.resolve(path);
            bb = java.nio.file.Files.readAllBytes(p);
            
            if doClose
                zipFileSystem.close();
            end
        end
    end
    
end


% function fstruct = make_file_struct( byteData, isDataLE )
%     % This function takes an array of data and returns a structure with a
%     % mfile object (an in memory file essentially).
%     % The isDataLE is 1 if the data in the file is Little Endian, 0 if the
%     % data is Big Endian.
%     persistent swapRequiredBE swapRequiredLE
%     
%     if isempty(swapRequiredBE)
%         swapRequiredLE = java.nio.ByteOrder.LITTLE_ENDIAN ~= java.nio.ByteOrder.nativeOrder();
%         swapRequiredBE = java.nio.ByteOrder.BIG_ENDIAN ~= java.nio.ByteOrder.nativeOrder();
%     end
% 
%     fid = mfile(typecast(byteData, 'uint8'));
%     fseek(fid, 0, 'bof');
% 
%     % determine if the data in the file needs to have its byte order
%     % swapped during reading
%     if isDataLE
%         requiresSwap = swapRequiredLE;
%     else
%         requiresSwap = swapRequiredBE;
%     end
% 
%     fstruct = struct('fid', fid, 'requiresSwap', requiresSwap, 'rr', rand(1,1));
% end

function fstruct = make_file_struct(path, isDataLE )
    % This function takes an array of data and returns a structure with a
    % mfile object (an in memory file essentially).
    % The isDataLE is 1 if the data in the file is Little Endian, 0 if the
    % data is Big Endian.

    % determine if the data in the file needs to have its byte order
    % swapped during reading
    if isDataLE
        fid = fopen(path, 'r', 'l');
    else
        fid = fopen(path, 'r', 'b');
    end

    fstruct = struct('fid', fid, 'requiresSwap', 0);
end


function tmp_folder = create_tmp_folder()    
    tmp_folder = tempname( [tempdir(), '/kinarm'] );
    mkdir(tmp_folder);  
end
