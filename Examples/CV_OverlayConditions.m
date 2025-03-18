% CV_OverlayConditions: Plot overlaid CVs from data files of experiments 
%   performed in different conditions, with legend and different colors 
%   that go from dark, cold colors to bright, hot colors.
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
expName = 'E2 and E3 (rough step2, coupling vs non coupling), 1st cycle, filter';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\02282025\E2 (rough step2 only, unbuffered coupling) CV 50mVps.DY20"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\02282025\E3 (rough step2, no coupling, NB incubation) CV 50mVps.txt"
};

% Experiment parameters
numCycles = 3;
cyclesToPlot = [1];
electrodeDiameter = 2; % in mm
pH = 13.7;
Eref = 0.222; % reference electrode potential vs SHE, in V
scanRate = 0.05; % in V/s

% YScaleFactor = 1e6 / ( pi * ( electrodeDiameter / 10 )^2 / 4 );
YScaleFactor = 1e6;

% Reading data
[potential, current] = readDataPath(dataPath, 1, 2);

for i = 1:length(current)
    % Plot only specified cycles
    [potential{i}, current{i}] = getCVCycle(potential{i}, current{i}, numCycles, cyclesToPlot);

    % Get time array of CV
    time = timeFromCV(potential{i}, scanRate);
    current{i} = filterCV(time, current{i}, [10 20]);

    % Convert potential from 3 M KCl to RHE
    % ERHE = @(E) Eref + pH * 0.059 + E;
    % 
    % potential{i} = ERHE(potential{i});
end

TEMPERATURE_COLOR = {
    [0.1000 0.1000 0.1000]      % dark grey
    [0.0000 0.4470 0.7410]      % blue
    [0.4660 0.6740 0.1880]      % green
    [0.9290 0.6940 0.1250]      % burnt yellow
    [0.8500 0.3250 0.0980]      % orange
};

[fig, ax] = plotXY(potential, current, ...
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', '{\iti} (μA)', ...
    'XLim', [-0.6 0], ...
    'YLim', [], ...
    'Color', TEMPERATURE_COLOR, ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'YScaleFactor', YScaleFactor, ...
    'FigureName', 'CV' ...
    );

labels = createLegendLabels([25 30 35 40 43], ' °C');

legend(ax, ...
    labels, ...
    'Location', 'best')

% legend(ax, ...
%     {'5 mV/s'; '50 mV/s'}, ...
%     'Location', 'best')

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)