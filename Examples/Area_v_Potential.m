% Plot Area vs E for Nile Blue experiment from data files.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   29 Aug 2024
clear
close all
clc

%% Basic Parameters
% Experiment name (comment out or leave blank to use file name)
expName = 'Area vs E slope overlay';

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

% Eonset = -0.19; % onset potential
% Ehalf = -0.34; % half-wave potential

ERange = {[-0.33 -0.19]; [-0.35 -0.22]; [-0.31 -0.19]};

for i = 1:nFiles
    % [~, EonsetIdx] = min(abs(potential{i} - Eonset));
    % [~, EhalfIdx] = min(abs(potential{i} - Ehalf));

    [~, E1Idx] = min(abs(potential{i} - ERange{i}(2)));
    [~, E2Idx] = min(abs(potential{i} - ERange{i}(1)));

    f = @(x, E) x(1) * E + x(2);

    potentialRange{i} = potential{i}(E1Idx:E2Idx);
    areaRange{i} = area{i}(E1Idx:E2Idx);

    [x, resnorm, ~, exitflag, output] = lsqcurvefit(f, ... function
        [1 1], ... initial values of the parameters
        potentialRange{i}, ... x data
        areaRange{i} ... y data
        );

    m{i} = x(1);
    b{i} = x(2);
    
    extendedERange{i} = stretch(potentialRange{i}, 5);

    plotXY(extendedERange{i}, f(x, extendedERange{i}), ...
        'Color', i, ...
        'LineStyle', '--', ...
        'Axes', ax);

    ax.YLim = [0 5e4];

    if i == 1
        [fig2, ax2] = plotXY(extendedERange{i}, f(x, extendedERange{i}), ...
            'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
            'YLabel', 'Fit {\itA}_{592}', ...
            'YLim', [0 5e4], ...
            'XLim', [-0.3 -0.2], ...
            'AspectRatio', 1.2, ...
            'FigureName', 'linear_fit', ...
            'PlotWidth', 5);
    else
        disp(i)
        plotXY(extendedERange{i}, f(x, extendedERange{i}), ...
            'Color', i, ...
            'Axes', ax2);
    end
end

legend(ax, ...
    {'25 °C'; '30 °C'; '35 °C'}, ...
    'Location', 'best')

legend(ax2, ...
    {'25 °C'; '30 °C'; '35 °C'}, ...
    'Location', 'best')

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveAllFigs(savePath, 'png', 'fig', 'pdf')

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)