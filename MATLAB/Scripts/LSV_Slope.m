% LSV: Plot Linear Sweep Voltammograms from data files.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   28 Aug 2024
clear
close all
clc

%% BASIC PARAMETERS
% Experiment name (comment out or leave blank to use file name)
expName = 'LSV 50μMNB overlay bkg subtracted zoom and slope (-0.24)';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08282024\rAg4 (1)\LSV 50uMNB (2) 25C.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08282024\rAg4 (1)\LSV 50uMNB (1) 30C.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08282024\rAg4 (1)\LSV 50uMNB (2) 35C.txt"
};

% Path to background files (one per line)
bkgPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08282024\rAg4 (1)\LSV Background (6) 25C.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08282024\rAg4 (1)\LSV Background (1) 30C.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08282024\rAg4 (1)\LSV Background (3) 35C.txt"
};

% Plotting options
YScaleFactor = 1e6;
offset = [-0.8e-6 -0.5e-6 -1.2e-6];

%% MAIN 
nFiles = length(dataPath); % number of files

potential = cell([nFiles 1]); % preallocate arrays
current = cell([nFiles 1]);

for i = 1:nFiles % read all data files
    [potential{i}, current{i}] = readData(dataPath{i}, 1, 2);
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
    'XLim', [-0.32 -0.24], ...
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


ERange = {[-0.27 -0.23]; [-0.27 -0.23]; [-0.27 -0.23]};

for i = 1:nFiles
    [~, E1Idx] = min(abs(potential{i} - ERange{i}(2)));
    [~, E2Idx] = min(abs(potential{i} - ERange{i}(1)));

    f = @(x, E) x(1) * E + x(2);

    potentialRange{i} = potential{i}(E1Idx:E2Idx);
    currentRange{i} = current{i}(E1Idx:E2Idx);

    [x, resnorm, ~, exitflag, output] = lsqcurvefit(f, ... function
        [1 1], ... initial values of the parameters
        potentialRange{i}, ... x data
        currentRange{i} ... y data
        );

    m{i} = x(1);
    b{i} = x(2);
    
    extendedERange{i} = stretch(potentialRange{i}, 5);

    plotXY(extendedERange{i}, f(x, extendedERange{i}), ...
        'Color', i, ...
        'LineStyle', '--', ...
        'YScaleFactor', YScaleFactor, ...
        'Axes', ax);

    if i == 1
        [fig2, ax2] = plotXY(extendedERange{i}, f(x, extendedERange{i}), ...
            'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
            'YLabel', 'Fit {\iti} (μA)', ...
            'XLim', [-0.32 -0.24], ...
            'AspectRatio', 1.2, ...
            'YScaleFactor', YScaleFactor, ...
            'FigureName', 'linear_fit', ...
            'PlotWidth', 5);
    else
        plotXY(extendedERange{i}, f(x, extendedERange{i}), ...
            'YScaleFactor', YScaleFactor, ...
            'Color', i, ...
            'Axes', ax2);
    end
end

legend(ax, ...
    {'25 °C'; '30 °C'; '35 °C'}, ...
    'Location', 'southeast')

legend(ax2, ...
    {'25 °C'; '30 °C'; '35 °C'}, ...
    'Location', 'southeast')

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)
