% RamanSpectra: Plot Raman spectrum.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   For documentation, see: github.com/jvhemmer/data-processing/
%   johann.hemmer@louisville.edu
%   15 Mar 2024
clear
close all
clc

%% Basic Parameters
% Experiment name (leave blank to use file name).
expName = 'Covalenty-attached vs physisorbed';

% Path to data files (char separated by space, semicolor or new line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\02142025\2025-02-14 15_25_17 E3 (rough) spot1 10FPS.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08152024\2024-08-15 12_43_08 r-Ag 3 roughening with NB OCP.csv"
};

bkgPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\02142025\2025-02-14 14_00_27 DC.csv"
};

frameRange = {[1, 120]; [1, 120]};

%% Execution
nFiles = length(dataPath);

% Process background spectrum
if not(isempty(bkgPath{1}))
    [~, bkgIntensity] = readSpectra(bkgPath);

    avgBkgIntensity = avgSpectra(bkgIntensity);
end

% Reading data
wavelength = cell([nFiles 1]);
intensity = cell([nFiles 1]);
ramanShift = cell([nFiles 1]);
corrIntensity = cell([nFiles 1]);
avgIntensity = cell([nFiles 1]);

for i = 1:nFiles
    % Read files
    [wavelength{i}, intensity{i}] = readSpectra(dataPath{i});

    % Convert wavelength to Raman shift
    ramanShift{i} = wavelengthToRS(wavelength{i}, 636.551);

    % Background subtraction
    corrIntensity{i} = intensity{i} - avgBkgIntensity;

    % Average the intensity
    avgIntensity{i} = avgSpectra(corrIntensity{i}, ...
        'FrameRange', frameRange{i});
end

x = ramanShift;
y = avgIntensity;

[fig, ax] = plotXY(x{1}, y{1}, ...
    'XLabel', 'Raman shift (cm^{−1})', ...
    'YLabel', 'Intensity (counts)', ...
    'XLim', [min(x{1}) max(x{1})], ...
    'YLim', [], ...
    'FigureName', 'spectrum', ...
    'AspectRatio', 2.4, ...
    'PlotWidth', 8);
    
if nFiles > 1
    for j = 2:nFiles
    plotXY(x{j}, y{j}, ...
        'Color', j, ...
        'Axes', ax);
    end

    legend(ax, ...
        {'Covalent attachment'; 'Physisorption'}, ...
        'Location', 'best')
end

%% Saving
savePath = createAnalysisFolder(dataPath{1}, expName);

saveAllFigs(savePath, 'fig', 'pdf', 'png')

% Saving the areas
% saveTable(peakPos, peakArea, ... 
%     'SavePath', savePath, ...
%     'VariableNames', {'Peak Raman Shift (cm-1)', 'Area'}, ...
%     'FileName', 'areas.txt');

% Copy files
copyFile(savePath, dataPath, bkgPath)

% Saving a report
saveReport(savePath)