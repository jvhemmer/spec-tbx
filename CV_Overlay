%OVERLAYCV Plot multiple CVs from data files.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   14 Mar 2024

clear
close
clc

%% Basic Parameters (edit here)
% Experiment name (comment out or leave blank to use file name)
expName = 'Overlay Temperature Gradient';

% Path to data files (one per line, separated by semicolon)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\04. Amin 1st Paper\Simulation\20240531\gradT H2O.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\04. Amin 1st Paper\Simulation\20240531\gradT ACN.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\04. Amin 1st Paper\Simulation\20240531\gradT DMF.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\04. Amin 1st Paper\Simulation\20240531\gradT DMSO.txt"
};

% Basic figure setup
xLabel = '{\itz} (mm)';
yLabel = '{\itT} (°C)';

yScalingFactor = 1e0; % Adjust scale, i.e., 1e3 for mA, 1e6 for μA, etc.
xLim = [0 4];
yLim = [];
xTicks = [];
yTicks = [];

% Figure style setup
fontName = 'Arial';
fontSize = 20;
numSize = 18;
lineWidth = 2;
color = {
    [0.1000 0.1000 0.1000];    % very dark grey
    [0.0000 0.4470 0.7410];    % blue
    [0.8500 0.3250 0.0980];    % orange
    [0.4660 0.6740 0.1880];    % green
};   
plotWidth = 5; % Length of the plot axes in inches
aspectRatio = 1.2; % Lenght/Height of the plot axes

legendLabels = {'H_{2}O'; 'ACN'; 'DMF'; 'DMSO'};

%% Reading data
data = cell([length(dataPath) 1]);
potential = cell([length(dataPath) 1]);
current = cell([length(dataPath) 1]);

for i = 1:1:length(dataPath)
    % Convert 'dataPath' to char in case it is string, to avoid problems
    dataPath{i} = char(dataPath{i});
    
    % Read the data contained in the file
    data{i} = readmatrix(dataPath{i});
    
    % Read the potential data (all rows of the 1st column)
    potential{i} = data{i}(:, 1);
    
    % Read the current data (all rows of the 2nd column)
    current{i} = data{i}(:, 2)*yScalingFactor;
end

%% Plotting
% Create figure and axes objects
fig = figure;
ax = axes(fig);

for i = 1:1:length(dataPath)
    lin = plot(ax, ...
        potential{i}, current{i}, ...
        'Color', color{i}, ...
        'LineWidth', lineWidth);
    
    hold on
end

xlabel(ax, ...
    xLabel, ...
    'FontName', fontName, ...
    'FontSize', fontSize, ...
    'Interpreter', 'tex')

ylabel(ax, ...
    yLabel, ...
    'FontName', fontName, ...
    'FontSize', numSize, ...
    'Interpreter', 'tex')

legend(ax, legendLabels, ...
     'FontName', fontName, ...
    'FontSize', fontSize, ...
    'Interpreter', 'tex')

set(fig, ...
    'Theme', 'light', ...
    'Units', 'inches')

set(ax, ...
    'FontName', fontName, ...
    'FontSize', numSize, ...
    'LineWidth', lineWidth, ...
    'TickLabelInterpreter', 'tex', ...
    'Box', 'on', ...
    'Units', 'inches')

axis tight

% If limits and/or ticks were specified, set them
if (exist('xLim', 'var'))
    if ~isempty(xLim)
        ax.XLim = xLim;
    end
end

if (exist('yLim', 'var'))
    if ~isempty(yLim)
        ax.YLim = yLim;
    end
end

if (exist('xTicks', 'var'))
    if ~isempty(xTicks)
        ax.XTick = xTicks;
    end
end

if (exist('yTicks', 'var'))
    if ~isempty(yTicks)
        ax.YTick = yTicks;
    end
end

% Configure exact position of the axes if 'plotWidth' exists
if (exist('plotWidth', 'var') || exist('aspectRatio', 'var'))
    ax.PositionConstraint = 'OuterPosition';

    plotHeight = plotWidth/aspectRatio;

    ax.Position([3 4]) = [plotWidth plotHeight];

    fig.Position([3 4]) = ax.OuterPosition([3 4]);
end

%% Creating folder to save analysis
% Get the parts of the file name and path;
[path, fileName, ext] = fileparts(dataPath{1});
file = [fileName ext];

warning('off', 'MATLAB:MKDIR:DirectoryExists')

if exist('expName', 'var')
    if isempty(expName)
        expName = fileName;
    end
else
    expName = fileName;
end

% Folder to save the analysis files
savePath = [path filesep expName '_Analysis'];

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
        {expName});
    if ~isempty(sel)
        % If user clicked 'Ok'
        if isempty(sel{1})
            % If provided input is blank
            error('No input provided.')
        elseif isequal(sel{1}, expName)
            % If the input is equal to expName, overwrite
            disp('Overwriting...')
            mkdir(savePath)

        else
            % If the input is different than expName, create new folder
            disp('Creating new folder...')
            expName = sel{1};
            savePath = [path filesep expName '_Analysis'];
            mkdir(savePath)

        end
    else
        % If user clicks 'Cancel' or closes the dialog box
        warning('Aborted by user.')
        return
    end
end

%% Saving figures
% Save .fig file
savefig(fig, ...
    [savePath filesep 'output.fig'])

% Save .png file
% ACS suggests a minimum resolution of 300 for color figures
exportgraphics(fig, ...
    [savePath filesep 'output.png'], ...
    'ContentType', 'image', ...
    'Resolution', 300) 

% Save .pdf (vectorized) file
exportgraphics(fig, ...
    [savePath filesep 'output.pdf'], ...
    'ContentType', 'vector')

% Save .svg (vectorized) file
saveas(fig, ...
    [savePath filesep 'output.svg'], ...
    'svg')

% Finished saving figures, it is now possible to close MATLAB
disp(['Done saving figures at ' savePath '.'])

%% Saving a copy of this script
callstack = dbstack();
mainScript = callstack(end).file;

% Save a copy of this script at the 'savePath' folder
copyPath = [savePath filesep mainScript];

copyfile(mainScript, copyPath)

%% Saving a report
% Get required dependencies to run the code
[fList, pList] = matlab.codetools.requiredFilesAndProducts(mainScript);

apps = struct2table(pList);
dependencies = fList';

reportPath = [savePath filesep 'report.txt'];

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

% Write dependencies used to the report
writelines('\\ Scripts/routines used', reportPath, WriteMode='append');

[nrows, ~] = size(dependencies);

for row = 1:nrows
    writelines(dependencies{row,:}, reportPath, WriteMode='append');
end

% Write data files used to the report
writelines('', reportPath, WriteMode='append');
writelines('\\ Data files used', reportPath, WriteMode='append');

writelines([path file], reportPath, WriteMode='append');
