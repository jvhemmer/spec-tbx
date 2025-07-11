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
"C:\Users\jhemmer\Box\Johann Hemmer Data\Nile Blue Activation Energy\2025\07072025\CV Nile Blue 100 mVps Plus2947 ch1 (2025-07-07 14_26_51) 10 uM NB 40C trial 3\2_CV Nile Blue 100 mVps Plus2947 ch1 (2025-07-07 14_26_51) 10 uM NB 40C trial 3 20250707 142723.csv"
};

% Experiment parameters
numCycles = 3;
cyclesToPlot = [1 2 3];
electrodeDiameter = 2; % in mm
% pH = 13.7;
% Eref = 0.222; % reference electrode potential vs SHE, in V
% scanRate = 0.05; % in V/s

% YScaleFactor = 1e6 / ( pi * ( electrodeDiameter / 10 )^2 / 4 );
YScaleFactor = 1e6;

% Reading data
[potential, current] = readDataPath(dataPath, 6, 8);

for i = 1:length(current)
    % Plot only specified cycles
    % [potential{i}, current{i}] = getCVCycle(potential{i}, current{i}, numCycles, cyclesToPlot);

    % Get time array of CV
    % time = timeFromCV(potential{i}, scanRate);
    % current{i} = filterCV(time, current{i}, [10 20]);

    % Convert potential from Ag/AgCl/KCl (3M) to RHE
    % ERHE = @(E) Eref + pH * 0.059 + E;
end

[fig, ax] = plotXY(potential, current, ...
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', '{\iti} (μA)', ...
    'XLim', [-0.6 0], ...
    'YLim', [-25 5], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'YScaleFactor', YScaleFactor, ...
    'MinusSignOnAx', true, ...
    'FigureName', 'CV');

% legend(ax, ...
%     {'Successful condition'; 'Condition 2'; 'Condition 3'}, ...
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