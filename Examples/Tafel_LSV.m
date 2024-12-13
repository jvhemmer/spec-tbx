% Tafel analysis for LSV data.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   For documentation, see: github.com/jvhemmer/data-processing/
%   johann.hemmer@louisville.edu
%   4 Sep 2024
clear
close all
clc

%% Basic Parameters
% Path to data files (one per line)
dataPath = { % LSV data to average
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08282024\rAg4 (1)\LSV 50uMNB (2) 25C.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08282024\rAg4 (1)\LSV 50uMNB (1) 30C.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08282024\rAg4 (1)\LSV 50uMNB (2) 35C.txt"
};

% Path to background files (one per line)
bkgPath = { % background LSV data to average
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08282024\rAg4 (1)\LSV Background (6) 25C.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08282024\rAg4 (1)\LSV Background (1) 30C.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08282024\rAg4 (1)\LSV Background (3) 35C.txt"
};

% Experimental
electrodeDiameter = 2; % mm

% Plotting options
YScaleFactor = 1e6;
offset = [-0.8e-6 -0.5e-6 -1.2e-6];

%% MAIN 
electrodeArea = pi * (electrodeDiameter / 10)^2 / 4; % cm²

nFiles = length(dataPath); % number of files

potential = cell([nFiles 1]); % preallocate arrays
current = cell([nFiles 1]);

for i = 1:nFiles % read all data files
    [potential{i}, current{i}] = readData(dataPath{i}, 1, 2);

    currentDensity{i} = current{i} ./ electrodeArea;

    logj = log10(abs(currentDensity{i}));
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



%% Saving
savePath = createAnalysisFolder(sersPath{1}, expName);

saveAllFigs(savePath, 'fig', 'pdf', 'png')
disp(['Done saving figures at ' savePath '.'])

% Saving the areas
saveTable(potential', peakArea, ... 
    'SavePath', savePath, ...
    'VariableNames', {'Potential (V)', 'Area'}, ...
    'FileName', 'areas.txt');

% Copy files
copyFile(savePath, sersPath, bkgPath)

% Saving a report
saveReport(savePath)