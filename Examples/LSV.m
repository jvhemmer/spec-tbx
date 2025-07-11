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
expName = "LSVs bkg (1st trial 4-24-25) corrected ";

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04192025\E11 (same as E7, E9, rough, in 1 uM NB sol)\LSV 5mVps 24.8C.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04192025\E11 (same as E7, E9, rough, in 1 uM NB sol)\LSV 5mVps 30.1C.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04192025\E11 (same as E7, E9, rough, in 1 uM NB sol)\LSV 5mVps 35.6C.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04192025\E11 (same as E7, E9, rough, in 1 uM NB sol)\LSV 5mVps 39.4C.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04192025\E11 (same as E7, E9, rough, in 1 uM NB sol)\LSV 5mVps 45.3C.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04192025\E11 (same as E7, E9, rough, in 1 uM NB sol)\LSV 5mVps 50.5C.txt"
};

% Path to background files (one per line)
bkgPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04242025\BKG LSV 5mVps 25.0C.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04242025\BKG LSV 5mVps 30.0C.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04242025\BKG LSV 5mVps 35.2C.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04242025\BKG LSV 5mVps 40.6C.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04242025\BKG LSV 5mVps 45.7C.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04242025\BKG LSV 5mVps 49.6C.txt"
};

% Plotting options
YScaleFactor = 1e6; 
% offset = [-0.8e-6 -0.5e-6 -1.2e-6];

% Experimental params
pH = 5;
ERHE = @(E) 0.197 + pH*0.059 + E;
% electrodeDiameter = 0.2; % in cm
% filter = {[0.015 2.5]; [0.0047 2.5]; [0.0047 2.5]; [0.0047 2.5]; [0.0047 2.5]};
% solResistance = [12.4 10.5 11.2 10.8 10.6];

%% MAIN 
% Read data
[potential, current] = readDataPath(dataPath, 1, 2);

nFiles = length(dataPath); % number of files

% Data processing (comment out what is not necessary)
% Process background 
if not(isempty(bkgPath))
    nBkg = length(bkgPath);
    bkgCurrent = cell([nFiles 1]);
    for i = 1:nBkg
        [~, bkgCurrent{i}] = readData(bkgPath{i}, 1, 2);

        current{i} = current{i} - bkgCurrent{i}; % Subtract background current
    end
end

% Correction and conversions
for i = 1:nFiles
    % potential{i} = potential{i}/1000; % convert from mV
    % potential{i} = potential{i} - (current{i} * solResistance(i)); % iR correction
    % current{i} = current{i} - offset(i); % offset data
    % time = timeFromCV(potential{i}, 0.005); % calculate time for filtering
    % current{i} = filterCV(time, current{i}, filter{i}, "filterOrder", 2); % apply filter
    % potential{i} = ERHE(potential{i}); % convert potential from Ag/AgCl to RHE
    % current{i} = current{i} / (pi * electrodeDiameter^2 / 4); % calculate current density
end

[fig, ax] = plotXY(potential, current, ... 
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', '{\iti} (μA)', ...
    'YLim', [-2 8], ...
    'XLim', [-0.6 0], ...
    'XTick', [], ...
    'Color', SpecTbx.Colors.Heat, ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'FigureName', 'LSV', ...
    'YScaleFactor', YScaleFactor);

% Create a vertical line for the E0'
xl = xline(ax, -0.237, '-', "{\itE}^0'");
xl.FontSize = ax.FontSize;
xl.FontName = ax.FontName;
xl.LineWidth = ax.LineWidth;

labels = createLegendLabels(25:5:50, Decimals=1);

legend(ax, ...
    labels, ...
    'FontSize', ax.FontSize, ...
    'Location', 'best')

% Annotation in the plot
% 
% formatSpec = '%.1f';
% str = append("{\itT} = ", num2str(Tm,formatSpec), " ± ", num2str(Ts,formatSpec), " °C");
% an = annotation(fig, 'textbox', String=str, FitBoxToText='on', LineWidth=1.5, FontName='Arial', FontSize=16);
% an.Units = 'inches';
% an.Position = [ax.Position(1) + 0.15, ax.Position(3) - an.Position(3) - 0.2, an.Position(3), an.Position(4)];

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveFig(fig, 'output', savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)
