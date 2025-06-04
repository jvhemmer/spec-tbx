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
expName = 'Test';

% Path to data files (char separated by space, semicolor or new line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\02142025\2025-02-14 13_31_38 NB in coverslip (592cm-1 at 636.2nm).csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\02142025\2025-02-14 13_34_09 DC.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\02142025\2025-02-14 14_04_18 E1 (smooth1) spot1.csv"
};

% Background, if exists
bkgPath = {
    
};

% Parameters
laserWavelength = 636.551;
% frameRange = {[1, 120]; [1, 120]}; % Range of frames to plot
offset = [3e4 -3e4 0];

%% Execution
nFiles = length(dataPath);

% Process background spectrum
if not(isempty(bkgPath))
    [~, bkgIntensity] = readSpectra(bkgPath);

    avgBkgIntensity = avgSpectra(bkgIntensity);
else
    avgBkgIntensity = 0;
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

x = ramanShift;
y = avgIntensity;

% Apply offsets
for i = 1:nFiles
    y{i} = y{i} + offset(i);
end

[fig, ax] = plotXY(x, y, ... 
    'XLabel', 'Raman shift (cm^{−1})', ...
    'YLabel', 'Intensity (counts)', ...
    'XLim', [min(x{1}) max(x{1})], ...
    'AspectRatio', 0.75, ...
    'PlotWidth', 2, ...
    'LineWidth', 2, ...
    'FigureName', 'spectrum');

legend(ax, ...
    {'Covalent attachment'; 'Physisorption'}, ...
    'Location', 'best')

%% Saving
savePath = createAnalysisFolder(dataPath{1}, expName);

saveAllFigs(savePath, 'fig', 'pdf', 'png')

% Copy files
copyFile(savePath, dataPath, bkgPath)

% Saving a report
saveReport(savePath)