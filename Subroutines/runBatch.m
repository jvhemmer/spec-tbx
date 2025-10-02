function runBatch(scriptFile, varargin)
% runBatch('EfieldMap_Interp_2DInput.m', 'dataPath', ["C:\file1.txt" "C:\file2.txt"], 'wl', [473 473], 'I0', [0.64 0.96])
% Aligned combinations: i-th element of each values vector is used together.
%
% Features:
% - Executes each temp script in an isolated function workspace so 'clear' inside
%   the script cannot nuke runBatch's variables (like tmpPath).
% - If the original script defines/uses a variable as a cell (e.g., dataPath{1}
%   or dataPath = {...}), then string inputs for that variable are auto-wrapped
%   as a 1×1 cell: {'C:\...'} so your script's dataPath{1} keeps working.
%
% Notes:
% - It replaces *all* assignments to that variable in the temp copy.
% - Values must be scalars per run. Strings are fine; vectors will be inserted
%   literally (e.g., [1 2 3]) if you pass them.

    if mod(nargin-1, 2) ~= 0
        error('Name/values must come in pairs: runBatch(file,''name1'',vals1,''name2'',vals2,...)');
    end
    if ~isfile(scriptFile)
        error('Script "%s" not found.', scriptFile);
    end

    nPairs = (nargin-1)/2;
    names  = cell(1,nPairs);
    vals   = cell(1,nPairs);
    N = [];

    for k = 1:nPairs
        names{k} = varargin{2*k-1};
        v = varargin{2*k};
        if isstring(v) && isscalar(v)
            v = char(v);                 % scalar string -> char
        elseif isstring(v)               % string array -> cellstr
            v = cellstr(v(:));
        end
        if ischar(v)
            v = {v};                     % single char -> 1×1 cell so indexing by i works
        end
        if ~(isscalar(v) || isvector(v))
            error('Values for "%s" must be a vector (aligned by index).', names{k});
        end
        vals{k} = v;
        if isempty(N)
            N = numel(v);
        elseif numel(v) ~= N
            error('All value arrays must have the same length. "%s" has %d, expected %d.', ...
                  names{k}, numel(v), N);
        end
    end

    originalText = fileread(scriptFile);

    % Pre-compute which variables should be wrapped as cells for string inputs
    wrapAsCell = false(1,nPairs);
    for k = 1:nPairs
        wrapAsCell(k) = needsCellWrapper(originalText, names{k});
    end

    for i = 1:N
        txt = originalText;

        % Replace/inject assignments for this run
        for k = 1:nPairs
            v = vals{k};
                if ~iscell(v) 
                    v = num2cell(v);
                end
            v = v{i}; % scalar for this run
            txt = setVarEverywhere(txt, names{k}, formatVal(v, wrapAsCell(k)));
        end

        % Write temp script
        tmpPath = [tempname, '.m'];
        fid = fopen(tmpPath,'w');
        if fid < 0, error('Could not create temp file.'); end
        fwrite(fid, txt);
        fclose(fid);

        try
            % Run in isolated workspace so 'clear' in the script cannot wipe runBatch vars
            runScriptIsolated(tmpPath);
        catch ME
            deleteIfExists(tmpPath);
            rethrow(ME);
        end
        deleteIfExists(tmpPath);
    end
end

% --- Run script in an isolated function workspace
function runScriptIsolated(p)
    run(p);
end

% --- Replace all assignments to varName; inject at top if none found
function txtOut = setVarEverywhere(txtIn, varName, valStr)
    vn  = regexptranslate('escape', varName);
    pat = ['(?m)^(?!\s*%)\s*' vn '\s*=\s*[^;]*;'];   % non-comment assignment lines
    [s,e] = regexp(txtIn, pat, 'start', 'end');

    rep = [varName ' = ' valStr ';'];

    if isempty(s)
        header = sprintf('%% Injected by runBatch on %s\n%s\n', datestr(now), rep);
        txtOut = [header, txtIn];
        return
    end

    % Splice together: original chunks + our replacement text (no regex replace)
    pieces = cell(1, 2*numel(s)+1);
    last = 1;
    for i = 1:numel(s)
        pieces{2*i-1} = txtIn(last:s(i)-1);
        pieces{2*i}   = rep;
        last = e(i)+1;
    end
    pieces{end} = txtIn(last:end);
    txtOut = [pieces{:}];
end

% --- Format a value as MATLAB code, with optional cell wrapping for strings
function s = formatVal(v, wrapCell)
    if isnumeric(v)
        if isscalar(v)
            s = sprintf('%.15g', v);
        else
            s = ['[', strjoin(arrayfun(@(x)sprintf('%.15g',x), v(:).', 'UniformOutput', false), ' '), ']'];
        end
    elseif isstring(v) || ischar(v)
        lit = strrep(char(v), '''', '''''');   % escape single quotes only
        s = ['''' lit ''''];                   % backslashes stay as-is
        if wrapCell
            s = ['{' s '}'];                   % e.g., {'C:\path\file.txt'}
        end
    elseif iscell(v)
        parts = cellfun(@(q) formatVal(q,false), v, 'UniformOutput', false);
        s = ['{' strjoin(parts, ', ') '}'];
    else
        error('Unsupported value type: %s', class(v));
    end
end

% --- Heuristic: does the script use/define varName as a cell? If so, wrap strings in { }
function tf = needsCellWrapper(txt, varName)
    vn = regexptranslate('escape', varName);
    patAssignCell = ['(?m)^\s*' vn '\s*=\s*\{'];      % var = { ... };
    patUseCell    = [vn '\s*\{'];                     % var{ ... }
    tf = ~isempty(regexp(txt, patAssignCell, 'once')) || ...
         ~isempty(regexp(txt, patUseCell,    'once'));
end

function deleteIfExists(p)
    if exist(p,'file'), delete(p); end
end


