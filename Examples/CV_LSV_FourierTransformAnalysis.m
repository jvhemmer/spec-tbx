% CV_LSV_FourierTransformAnalysis: Plot CVs and their FTs from data files.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   26 Feb 2025
clear
close all
clc

%% Basic Parameters
% Experiment name (comment out or leave blank to use file name)
expName = '$ FT';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\Box\Johann Hemmer Data\Nile Blue Activation Energy\2025\07192025\CV Nile Blue 100 mVps Plus2947 ch1 (2025-07-19 17_19_35) 50 uM NB 30C commercial trial 2\2_CV Nile Blue 100 mVps 20250719 171953.csv"
};

% General parameters
saveToAnalysisFolder = false;

% Experiment parameters
scanRate = 0.1; % V/s
cycles = 1;
electrodeDiameter = 2; % mm
% YScaleFactor = 1e6 / ( pi * ( electrodeDiameter / 10 )^2 / 4 );
YScaleFactor = 1e6;
pH = 13.7;
Eref = 0.222;

% Reading data
nFiles = length(dataPath);
potential = cell([nFiles 1]);
current = cell([nFiles 1]);
filtcurrent = cell([nFiles 1]);
FTcurrent = cell([nFiles 1]);
filtFTcurrent = cell([nFiles 1]);

ERHE = @(E) Eref + pH*0.059 + E; % Nersnt for converting reference

[potential, current] = readDataPath(dataPath, 6, 8);

% Process data
for i = 1:nFiles
    % potential{i} = ERHE(potential{i}); % Convert reference

    % Calculate FT of unadulterated data
    time = timeFromCV(potential{1}, scanRate);
    % current{i} = filterCV(time, current{i}, [0.0980 0.1597]);
    frequencyStep = 1/(time(2) - time(1));
    FTcurrent{i} = abs(fft(detrend(current{i})));
    freqs = (0:length(FTcurrent{i}) - 1) * frequencyStep / length(FTcurrent{i});
    FTcurrent{i} = FTcurrent{i}/length(freqs);
    freqLimit = freqs(end)/2;
end

[fig2, ax2] = plotXY(freqs, FTcurrent, ...
    'XLabel', 'ƒ (Hz)', ...
    'YLabel', '{\itF}(ƒ) (μA s)', ...
    'XLim', [freqLimit/100 freqLimit], ...
    'YLim', [], ...
    'LineStyle', '-', ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'YScaleFactor', 1, ...
    'FigureName', 'FourierTransform');

[fig, ax] = plotXY(potential, current, ...
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', '{\iti} (μA)', ...
    'XLim', [], ...
    'YLim', [], ...
    'LineStyle', '-', ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'YScaleFactor', YScaleFactor, ...
    'FigureName', 'currentResponse');

if saveToAnalysisFolder
    % Creating folder to save analysis
    savePath = createAnalysisFolder(dataPath{1}, expName);

    % Copy files
    copyFile(savePath, dataPath)
else
    savePath = fileparts(dataPath{1});
end

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

