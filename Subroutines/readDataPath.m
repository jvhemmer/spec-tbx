function varargout = readDataPath(datapath, columns)
% readDataPath: Reads data files from paths and outputs values ans columns.
%
%   Opens any character-separated value file (TXT, CSV, XLSX, etc.) in
%   which the data is organized by columns (e.g., variable 1 is in the
%   first column, variable 2 is in the second, etc.), reads the values of
%   the specified columns and outputs those values to separate variables.
%   The number of columns specified MUST match the number of the number of
%   output variables.
%
%   Arguments:
%       datapath: path to the data to be opened.
%       columns: integers representing which columns of the data file are
%       to be read and have their values stored in the variables listed in
%       the output. Separated by comma.
%
%   Example:
%       [A, B] = readData('C:\Users\...', 1, 2) 
%       [potential, current, frames] = readData(path, 1, 3, 4)

    arguments
        datapath (1,:) cell
    end

    arguments (Repeating)
        columns (1,1) int8
    end
    
    if length(columns) ~= nargout
        error('The number of columns must match the number of outputs.')
    end
    
    nPaths = length(datapath);

    % Preallocate arrays
    data = cell([1 nPaths]);
    varargout = cell([nargout nPaths]);

    for i = 1:nPaths
        disp(append('Opening ', datapath{i}, '...'))

        data{i} = readmatrix(datapath{i});


        % Create combined output         
        for n = 1:nargout
            varargout{n}{i} = data{i}(:, columns{n});
        end
    end
    



end