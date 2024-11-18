function [savePath] = createAnalysisFolder(path, name)
% createAnalysisFolder: functions to facilitate the creation of an Analysis
% folder. If a file path is provided in "path", the function creates a
% folder with the same name in the same path but appends "_Analysis" to the
% folder's name. If it is a folder, the folder is created.

    arguments
        path (1,:) char
        name (1,:) char = ''
    end

    if isfolder(path)
        savePath = path;
    else
        % Get the parts of the file name and path;
        [folderPath, fileName, ext] = fileparts(path);
    
        warning('off', 'MATLAB:MKDIR:DirectoryExists')
    
        if isempty(name)
            name = fileName;
        end

        % Folder to save the analysis files
        savePath = [folderPath filesep name '_Analysis'];
    end
    
    if ~exist(savePath, 'dir')
        % If 'savePath' does not exist, create it
        mkdir(savePath);
    else
        % If 'savePath' already exists, ask is user wants to overwrite
        sel = inputdlg( ...
            ['Directory ' savePath ' already exists. Input a new ' ...
            'experiment name or leave same to overwrite. Alternatively, ' ...
            'select Cancel to abort.'], ...
            'Directory already exists.', ...
            1, ...
            {name});
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
                savePath = [folderPath filesep name '_Analysis'];
                mkdir(savePath)
    
            end
        else
            % If user clicks 'Cancel' or closes the dialog box
            error('Aborted by user.')
        end
    end
end

% ---