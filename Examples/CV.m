% CV: Plot CVs from data files.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   20 Aug 2024
clear
close
clc

%% Basic Parameters
% Experiment name (comment out or leave blank to use file name)
expName = '';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\Box\Johann Hemmer Data\ORR\2025\07092025\ORR CV 1000 mVps Plus2947 ch1 (2025-07-09 17_12_05) -0.7 to -2.4 at 1000 mVps\2_ORR CV 1000 mVps Plus2947 ch1 (2025-07-09 17_12_05) -0.7 to -2.4 at 1000 mVps 20250709 171229.csv"
};

bkgPath = {
};

% Experiment parameters
segmentsToPlot = [1 2 3 4 5 6];
electrodeDiameter = 2; % in mm
% pH = 13.7;
% Eref = 0.222; % reference electrode potential vs SHE, in V
Elow = -0.6; % in V
Ehigh = 0; % in V
scanRate = 0.1; % in V/s
% filterFreqs = {[80 90]; [98 104]; [114 116]}; % for 0.5 mV sampling
filterFreqs = [40 50]; % for 1 mV sampling

% YScaleFactor = 1e6 / ( pi * ( electrodeDiameter / 10 )^2 / 4 );
YScaleFactor = 1e6;

%% Read files
% Reading data
[potential, current] = readDataPath(dataPath, 6, 8);
% [bkgPotential, bkgCurrent] = readDataPath(bkgPath, 6, 8);

%% Processing
% Background correction
% current = subtractBkg(current, bkgCurrent, AverageEveryN=3, Interpolate=true);

time = cell(length(dataPath), 1);

for i = 1:length(current)
    % Get time array of CV
    % time{i} = timeFromCV(potential{i}, scanRate);

    % Filter out selected frequencies
    % current{i} = filterCV(time{i}, current{i}, filterFreqs);

    % Plot only specified cycles    
    % [potential{i}, current{i}] = splitCVToSegments(potential{i}, current{i}, scanRate, -0.6, 0);
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
    'YLabel', '{\iti} (μA)', ...
    'XLim', [], ...
    'YLim', [], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'YScaleFactor', YScaleFactor, ...
    'MinusSignOnAx', true, ...
    'FigureName', figName);

% legend(ax, ...
%     {'1st cycle'; '2nd cycle'; '3rd cycle'}, ...
%     'Location', 'best')

% Creating folder to save analysis
% savePath = createAnalysisFolder(dataPath{1}, expName);
savePath = fileparts(dataPath{1});

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Copy data files
% copyFile(savePath, dataPath)