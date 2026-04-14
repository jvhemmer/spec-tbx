% Plot CVs from data files.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   20 Aug 2024
clear
close
clc

%% BASIC PARAMETERS
% Experiment name (comment out or leave blank to use file name)
expName = '';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\Box\Johann Hemmer Data\ORR\2025\11052025\2025-11-05 10_53_12 GCE TBAClO4 in ACN p-Ar 100mVps\2025-11-05 10_53_12 GCE TBAClO4 in ACN p-Ar 100mVps 20251105 105501.csv"
};

bkgPath = {
};

% General parameters
saveToAnalysisFolder = true;

% Experiment parameters
segmentsToPlot = [5 6];
electrodeDiameter = 3; % in mm
% pH = 13.7;
% Eref = 0.222; % reference electrode potential vs SHE, in V
Elow = -2.4; % in V
Ehigh = -0.7; % in V
scanRate = 0.1; % in V/s
% filterFreqs = {[80 90]; [98 104]; [114 116]}; % for 0.5 mV sampling
% filterFreqs = [40 50]; % for 1 mV sampling

YScaleFactor = 1e3 / ( pi * ( electrodeDiameter / 10 )^2 / 4 );
% YScaleFactor = 1e6;

%% MAIN
% Reading data
[potential, current] = readDataPath(dataPath, 6, 8);
% [bkgPotential, bkgCurrent] = readDataPath(bkgPath, 5, 6);

% Background correction
% current = subtractBkg(current, bkgCurrent, AverageEveryN=3, Interpolate=true);

% time = cell(length(dataPath), 1);

for i = 1:length(current)
    % Get time array of CV
    % time{i} = timeFromCV(potential{i}, scanRate);

    % Filter out selected frequencies
    % current{i} = filterCV(time{i}, current{i}, filterFreqs);

    % Plot only specified cycles    
    % [potential{i}, current{i}] = splitCVToSegments(potential{i}, current{i}, scanRate, Elow, Ehigh);
    % potential{i} = potential{i}(segmentsToPlot);
    % potential{i} = vertcat(potential{i}{:});
    % current{i} = current{i}(segmentsToPlot);
    % current{i} = vertcat(current{i}{:});

    % Convert potential from Ag/AgCl/KCl (3M) to RHE
    % ERHE = @(E) Eref + pH * 0.059 + E;
end

if isempty(expName)
    figName = 'CV';
else
    figName = expName;
end

[fig, ax] = plotXY(potential, current, ...
    'XLabel', '{\itE} (V vs. Ag/Ag^+)', ...
    'YLabel', '{\itj} (mA cm^{−2})', ...
    'XLim', [Elow Ehigh], ...
    'YLim', [], ...
    'XTick', [], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'YScaleFactor', YScaleFactor, ...
    'MinusSignOnAx', true, ...
    'FigureName', figName);


% ax.Children((end+1)-2).Color = [0.1 0.1 0.1];
% ax.Children((end+1)-2).Color = ax.Children((end+1)-1).Color;
% uistack(ax.Children((end+1)-2), "bottom")

% legend(ax, ...
%     {'O_2'; 'N_2'}, ...
%     'Location', 'southeast')

% Creating folder to save analysis
if saveToAnalysisFolder == true
    % Creating folder to save analysis
    savePath = createAnalysisFolder(dataPath{1}, expName);
    
    % Copy files
    if isfile(dataPath{1})
        copyFile(savePath, dataPath)
    end
elseif saveToAnalysisFolder == false
    savePath = fileparts(dataPath{1});
elseif strcmp(saveToAnalysisFolder, 'parent')
    parentPath = fileparts(fileparts(dataPath{1}));
    savePath = createAnalysisFolder(parentPath, expName);
end

% Saving figures
saveFig(fig, 'output', savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Save workspace
save(append(savePath, filesep, append(expName,'_workspace.mat')))