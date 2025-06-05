function saveReport(savePath, varargin)
% saveReport: Saves the scripts, subroutines and a report.
%
%   Created by Johann Hemmer
%   johann.hemmer@louisville.edu
%   github.com/jvhemmer/data-processing
%   17 Aug 2024
%
%   This function will save a copy of the script and append to it the code
%   of all subroutines used. A TXT file will also be saved containing the
%   information about user, date and time, MATLAB version, etc.
%
%   Arguments:
%       savePath: path to a folder where all the output will be saved.
%
%   Example:
%   saveReport(path)
%   saveReport("C:\Path\To\Output\")

    % Get the name of the script that was run in order to save a copy in
    % order to save a copy of it
    callstack = dbstack();
    mainScript = callstack(end).file;
    copyPath = append(savePath, filesep, mainScript);
    copyfile(mainScript, copyPath)

    % Get required dependencies to run the code
    [fList, pList] = matlab.codetools.requiredFilesAndProducts(mainScript);

    apps = struct2table(pList);
    dependencies = fList';

    reportPath = append(savePath, filesep, 'report.txt');

    % Write preamble
    writelines('\\ ANALYSIS REPORT', reportPath, WriteMode='overwrite');
    writelines(['User: ' getenv('username')], reportPath, WriteMode='append');
    writelines(['OS: ' getenv('os')], reportPath, WriteMode='append');
    writelines(['Date: ' char(datetime)], reportPath, WriteMode='append');
    writelines('', reportPath, WriteMode='append');

    % Write apps used to the report
    writelines('\\ Apps used', reportPath, WriteMode='append');

    writetable(apps, ...
        reportPath, ...
        'Delimiter', '\t', ...
        'WriteVariableNames', true, ...
        'WriteMode','Append');

    writelines('', reportPath, WriteMode='append');

    writelines('\\ Scripts/routines used', reportPath, WriteMode='append');

    [nrows, ~] = size(dependencies);

    for row = 1:nrows
        writelines(dependencies{row,:}, reportPath, WriteMode='append');
    end

    writelines('', copyPath, WriteMode='append')
    writelines('%% Subroutines', copyPath, WriteMode='append')

    % Write dependencies used to the report
    subroutines = {};
    for i = 1:length(dependencies)
        [~, file, ext] = fileparts(dependencies{i});
        if isequal(mainScript, append(file, ext))
            continue
        end
        
        subroutines{end+1} = dependencies{i};
    end

    for sub = length(subroutines):-1:2
        subroutineScript = readlines(subroutines{sub});
        writelines(subroutineScript, copyPath, WriteMode='append')
        writelines('', copyPath, WriteMode='append')
    end

    disp(append('Saved report at: ', savePath))
end