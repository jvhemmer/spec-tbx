function saveReport(savePath, varargin)
% saveReport: Saves the script, its subroutines, and a report.
%
% Notes:
% - Detects the real caller even when invoked via runBatch/run/runScriptIsolated
% - Writes a copy of the main script to savePath (basename only)
% - Appends dependencies in readable order
% - Creates savePath if needed

    % --- figure out the main script that called us ---
    cs = dbstack('-completenames');

    % default: caller of saveReport (if exists)
    if numel(cs) >= 2
        mainScript = cs(2).file;
    else
        mainScript = cs(1).file;
    end

    % if an injected original name exists, prefer it
    try
        if evalin('caller','exist(''__ORIG_SCRIPT__'',''var'')')
            origName = evalin('caller','__ORIG_SCRIPT__');
            if ischar(origName) || isstring(origName)
                % resolve relative names against current folder
                cand = which(char(origName));
                if ~isempty(cand), mainScript = cand; end
            end
        end
    catch
        % ignore if we can't access caller
    end

    % walk up the stack to skip wrappers and MATLAB internals
    isWrapper = @(f) endsWith(f, {'saveReport.m','runBatch.m','runScriptIsolated.m','run.m'}) ...
                  || contains(f, [filesep 'toolbox' filesep]);
    for k = 2:numel(cs)
        if ~isWrapper(cs(k).file)
            mainScript = cs(k).file;
            break
        end
    end

    % --- destination paths (basename only) ---
    if ~exist(savePath,'dir'), mkdir(savePath); end
    [~, mainBase, mainExt] = fileparts(mainScript);
    copyPath   = fullfile(savePath, [mainBase mainExt]);
    reportPath = fullfile(savePath, 'report.txt');

    % --- copy the main script ---
    try
        if ~strcmpi(mainScript, copyPath)
            copyfile(mainScript, copyPath);
        end
    catch err
        % If copy failed for any other reason, at least create an empty file so writelines works
        warning('saveReport:copyfile', 'Could not copy "%s" to "%s": %s', mainScript, copyPath, err.message);
        fclose(fopen(copyPath,'w'));
    end

    % --- dependencies/products ---
    [fList, pList] = matlab.codetools.requiredFilesAndProducts(mainScript);
    dependencies = fList(:);  % cell column
    if isempty(pList)
        apps = table();       % empty table is fine for writetable
    else
        apps = struct2table(pList);
    end

    % --- write preamble ---
    writelines("\\ ANALYSIS REPORT", reportPath, WriteMode='overwrite');
    writelines(['User: ' getenv('username')], reportPath, WriteMode='append');
    writelines(['OS: '   getenv('os')],       reportPath, WriteMode='append');
    writelines(['Date: ' char(datetime)],     reportPath, WriteMode='append');
    writelines("", reportPath, WriteMode='append');

    % --- apps ---
    writelines("\\ Apps used", reportPath, WriteMode='append');
    if ~isempty(apps)
        writetable(apps, reportPath, 'Delimiter','\t', 'WriteVariableNames',true, 'WriteMode','Append');
    else
        writelines("(none detected)", reportPath, WriteMode='append');
    end
    writelines("", reportPath, WriteMode='append');

    % --- dependencies list ---
    writelines("\\ Scripts/routines used", reportPath, WriteMode='append');
    if ~isempty(dependencies)
        writelines(string(dependencies), reportPath, WriteMode='append');
    else
        writelines("(none detected)", reportPath, WriteMode='append');
    end

    % --- append subroutines' code to the copied script ---
    writelines("",            copyPath, WriteMode='append');
    writelines("%% Subroutines", copyPath, WriteMode='append');

    subroutines = {};
    for i = 1:numel(dependencies)
        [~, depBase, depExt] = fileparts(dependencies{i});
        if strcmpi([depBase depExt], [mainBase mainExt])
            continue
        end
        subroutines{end+1} = dependencies{i}; %#ok<AGROW>
    end

    % Append each subroutine's source
    for i = 1:numel(subroutines)
        try
            subSrc = readlines(subroutines{i});
            writelines(subSrc, copyPath, WriteMode='append');
            writelines("",     copyPath, WriteMode='append');
        catch err
            warning('saveReport:subroutine', 'Could not append "%s": %s', subroutines{i}, err.message);
        end
    end

    % Temporary workaround you noted
    writelines('end', copyPath, WriteMode='append');

    disp("Saved report at: " + savePath);
end
