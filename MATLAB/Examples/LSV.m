% LSV: Plot Linear Sweep Voltammograms from data files.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   28 Aug 2024
clear
close
clc

%% BASIC PARAMETERS
% Experiment name (comment out or leave blank to use file name)
expName = 'LSV -1 to 0.5V';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\09072024\LSV -1 to 0.5 at 50 mVps.txt"
};

% Path to background files (one per line)
bkgPath = {
};

% Plotting options
YScaleFactor = 1e6;
offset = [-0.8e-6 -0.5e-6 -1.2e-6];

pH = 13.7;
ERHE = @(E) 0.222 + 13.7*0.059 + E;

%% MAIN 
nFiles = length(dataPath); % number of files

potential = cell([nFiles 1]); % preallocate arrays
current = cell([nFiles 1]);

for i = 1:nFiles % read all data files
    [potential{i}, current{i}] = readData(dataPath{i}, 1, 2);

    potential{i} = ERHE(potential{i});
end

% Process background 
if not(isempty(bkgPath))
    nBkg = length(bkgPath);
    bkgCurrent = cell([nFiles 1]);
    for i = 1:nBkg
        [~, bkgCurrent{i}] = readData(bkgPath{i}, 1, 2);

        current{i} = current{i} - bkgCurrent{i}; % Subtract background current
        % current{i} = current{i} - offset(i);
    end
end

[fig, ax] = plotXY(potential{1}, current{1}, ... 
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', '{\iti} (μA)', ...
    'YLim', [], ...
    'XLim', [], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'FigureName', 'LSV', ...
    'YScaleFactor', YScaleFactor);
    
if nFiles > 1 % if more than one data, plot the rest
    for j = 2:nFiles
    plotXY(potential{j}, current{j}, ...
        'YScaleFactor', YScaleFactor, ...
        'Color', j, ...
        'Axes', ax);
    end
end

% ax.YTick = [];

% legend(ax, ...
%     {'25 °C'; '30 °C'; '35 °C'}, ...
%     'Location', 'southeast')

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveFig(fig, 'output', savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)
