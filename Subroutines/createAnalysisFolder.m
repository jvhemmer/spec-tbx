function [savePath] = createAnalysisFolder(path, name)
% createAnalysisFolder: functions to facilitate the creation of an Analysis
% folder. If a file path is provided in "path", the function creates a
% folder with the same name in the same path but appends "_Analysis" to the
% folder's name. If it is a folder, the folder is created.

    arguments
        path (1,:) char
        name (1,:) char = ''
    end

    % Get the parts of the file name and path;
    [folderPath, fileName, ext] = fileparts(path);

    if isfolder(path)
        if isempty(name)
            % If no experimental name was given, save at the given path
            savePath = path;
        else
            % If experimental name starts with '$', the user wants to
            % append something to the default exp name (from file name)
            if name(1) == '$'
                name = append(fileName, name(2:end));
            else
                % If experimental name was given, create a folder appending
                % "_Analysis" and save there
                savePath = append(path, filesep, name, "_Analysis");
            end
        end
    else
        warning('off', 'MATLAB:MKDIR:DirectoryExists')
    
        if isempty(name)
            name = fileName;
        else
            % If experimental name starts with '$', the user wants to
            % append something to the default exp name (from file name)
            if name(1) == '$'
                name = append(fileName, name(2:end));
            end
        end

        % Folder to save the analysis files
        savePath = append(folderPath, filesep, name, '_Analysis');
    end
    
    if ~exist(savePath, 'dir')
        % If 'savePath' does not exist, create it
        mkdir(savePath);
    else
        % If 'savePath' already exists, ask is user wants to overwrite
        winTitle = "Directory already exists";
        winDesc = append('Directory ', savePath, ' already exists. ', ...
            'Input a new experiment name or leave same to overwrite. ', ...
            'Alternatively, select Cancel to abort.');
    
        % Open a dialog window to get new save path from user
        sel = inputdlg(winDesc, winTitle, 1, {name});

        if ~isempty(sel)
            % If user clicked 'Ok'
            if isempty(sel{1})
                % If provided input is blank
                error('No input provided.')
            elseif isequal(sel{1}, name)
                % If the input is equal to expName, overwrite
                disp('Overwriting...')
                mkdir(savePath)
    
            else
                % If the input is different than expName, create new folder
                disp('Creating new folder...')
                name = sel{1};
                savePath = append(folderPath, filesep, name, '_Analysis');
                mkdir(savePath)
    
            end
        else
            % If user clicks 'Cancel' or closes the dialog box
            error('Aborted by user.')
        end
    end
end

% ---