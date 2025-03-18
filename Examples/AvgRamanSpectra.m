% RamanSpectra: Plot average of multiple Raman spectra.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   For documentation, see: github.com/jvhemmer/data-processing/
%   johann.hemmer@louisville.edu
%   2 Mar 2025
clear
close all
clc

%% Basic Parameters
% Experiment name (leave blank to use file name).
expName = 'Avg test';

% Path to data files (char separated by space, semicolor or new line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\02142025\2025-02-14 15_25_17 E3 (rough) spot1 10FPS.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08152024\2024-08-15 12_43_08 r-Ag 3 roughening with NB OCP.csv"
};

bkgPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\02142025\2025-02-14 14_00_27 DC.csv"
};

laserWavelength = 636.551; % in nm

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
    ramanShift{i} = wavelengthToRS(wavelength{i}, laserWavelength);

    % Background subtraction
    corrIntensity{i} = intensity{i} - avgBkgIntensity;

    % Average the intensity
    avgIntensity{i} = avgSpectra(corrIntensity{i});
end

% avgSpectrum is the average intensity between the different files, while
% avgIntensity is the average intensity between the frames of the same file
sumSpectrum = zeros([length(avgIntensity{1}) 1]);
totalFrames = 0;

for i = 1:nFiles
    sumSpectrum = sumSpectrum + avgIntensity{i};
end

avgSpectrum = sumSpectrum / nFiles;

x = ramanShift{1};
y = avgSpectrum;

[fig, ax] = plotXY(x, y, ...
    'XLabel', 'Raman shift (cm^{−1})', ...
    'YLabel', 'Intensity (counts)', ...
    'XLim', [min(x) max(x)], ...
    'YLim', [], ...
    'FigureName', 'spectrum', ...
    'AspectRatio', 2.4, ...
    'PlotWidth', 8);

%% Saving
savePath = createAnalysisFolder(dataPath{1}, expName);

saveAllFigs(savePath, 'fig', 'pdf', 'png')

% Saving the areas
saveTable(x, y, ... 
    'SavePath', savePath, ...
    'VariableNames', {'RS (cm-1)', 'Intensity'}, ...
    'FileName', 'avgSpectrum.txt');

% Copy files
copyFile(savePath, dataPath, bkgPath)

% Saving a report
saveReport(savePath)