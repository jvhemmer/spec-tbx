function varargout = readData(datapath, columns)
% readData: Reads data files and outputs values ans columns.
%
%   Opens any character-separated value file (TXT, CSV, XLSX, etc.) in
%   which the data is organized by columns (e.g., variable 1 is in the
%   first column, variable 2 is in the second, etc.), reads the values of
%   the specified columns and outputs those values to separate variables.
%   The number of columns specified MUST match the number of the number of
%   output variables.
%
%   Arguments:
%       datapath: path to the data to be opened. If not specified, will
%           prompt the user to select a file on the current working 
%           directory.
%       columns: integers representing which columns of the data file are
%       to be read and have their values stored in the variables listed in
%       the output. Separated by comma.
%
%   Example:
%       [A, B] = readData('C:\Users\...', 1, 2) 
%       [potential, current, frames] = readData(path, 1, 3, 4)

    arguments
        
        datapath (1,:) char = pwd
    end

    arguments (Repeating)
        columns (1,1) int8
    end
    
    if length(columns) ~= nargout
        error('The number of columns must match the number of outputs.')
    end

    % Prompt or get specified file
    if isfile(datapath)
        % If user wrote the path to a file, open that file directly
        [path, file, ext] = fileparts(datapath);
        file = [file ext];
    else 
        if isfolder(datapath)
            % If user wrote a folder, open that folder and prompt for file
            [file, path] = uigetfile({'*.*'}, ...
                'Select files to analyze', ...
                datapath, ...
                MultiSelect = 'on');
        else
            % If user did not specify a path, just open the current
            % working directory and prompt for file
            warning(append("Path not found. Prompting user for files", ...
                " in the current working folder."))
            [file, path] = uigetfile({'*.*'}, ...
                'Select files to analyze.', ...
                pwd, ...
                'MultiSelect', 'on');
        end
    end

    % If only one file was selected, make file a cell array
    if ~iscell(file)
        if isempty(file) | file == 0
            error('No file selected.')
        else
            file = {file};
        end
    end

    % Read each data file
    nFiles = length(file);

    data = cell([1 nFiles]); % Preallocate arrays
    filePath = cell([1 nFiles]);

    for ifile = 1:length(file)
        filePath{ifile} = append(path, filesep, file{ifile});
        disp(['Opening ' file{ifile} '...'])

        data{ifile} = readmatrix(filePath{ifile});
    end
    
    % Create combined output 
    varargout = num2cell(zeros(1, nargout));

    for n = 1:length(varargout)
        varargout{n} = {};
        if length(filePath) > 1
            for ifile = 1:length(filePath)
                varargout{n}{ifile} = data{ifile}(:, columns{n});
            end
        else
            varargout{n} = data{ifile}(:, columns{n});
        end
    end
end