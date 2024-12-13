function dataTable = saveTable(var, options)
%SAVETABLE Summary of this function goes here
%   Detailed explanation goes here

    arguments (Repeating)
        var
    end

    arguments
        options.SavePath (1,:) char = pwd
        options.VariableNames = []
        options.FileName (1,:) char = 'output.txt'
        options.Delimiter (1,:) char = '\t'
    end

    if strcmpi(options.SavePath, pwd)
        warning("Save path not specified. Saving at current directory.")
    end

    outputPath = append(options.SavePath, filesep, options.FileName);

    if not(isempty(options.VariableNames))
        if length(options.VariableNames) ~= length(var)
            error('Number of variables must equal number of variable names.')
        else
            dataTable = table(var{:}, 'VariableNames', options.VariableNames);
        end
    else
        dataTable = table(var{:});
    end

    writetable(dataTable, outputPath, 'Delimiter', options.Delimiter)
end