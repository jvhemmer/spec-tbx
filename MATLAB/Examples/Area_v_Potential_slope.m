% Plot Area vs E for Nile Blue experiment from data files.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   29 Aug 2024
clear
close
clc

%% Basic Parameters
% Experiment name (comment out or leave blank to use file name)
expName = 'Area vs E overlay';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08292024\rAg1 LSV\LSV 1uMNB 5mVps 25C (triplicate)_Analysis\areas.txt" 
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08292024\rAg1 LSV\LSV 1uMNB 5mVps 30C (triplicate)_Analysis\areas.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08292024\rAg1 LSV\LSV 1uMNB 5mVps 35C (triplicate)_Analysis\areas.txt"
};

nFiles = length(dataPath);

% Reading data
potential = cell([nFiles 1]);
area = cell([nFiles 1]);

for i = 1:nFiles
    [potential{i}, area{i}] = readData(dataPath{i}, 1, 2);
    % area{i} = normalize(area{i}, 'range', [0 1]);
end

[fig, ax] = plotXY(potential{1}, area{1}, ...
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', '{\itA}_{592}', ...
    'YLim', [], ...
    'AspectRatio', 1.2, ...
    'FigureName', 'area_vs_pot', ...
    'PlotWidth', 5);
    
if nFiles > 1
    for j = 2:nFiles
    plotXY(potential{j}, area{j}, ...
        'Color', j, ...
        'Axes', ax);
    end
end

legend(ax, ...
    {'25 °C'; '30 °C'; '35 °C'}, ...
    'Location', 'best')

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveFig(fig, 'output', savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)