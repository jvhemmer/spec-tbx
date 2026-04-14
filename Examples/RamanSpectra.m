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
expName = 'AgO peak';

% Path to data files (char separated by space, semicolor or new line)
dataPath = {
"C:\Users\jhemmer\Box\Johann Hemmer Data\Aq CO₂RR EC-SERS with r-Ag\2024\01 Jan\01122023\2024-01-12 13_50_49 r-Ag2 in p-0.5M_NaHCO3_pH=adj E = -0.2V pos=-20,0 cw_1300.csv"
"C:\Users\jhemmer\Box\Johann Hemmer Data\Aq CO₂RR EC-SERS with r-Ag\2024\01 Jan\01122023\2024-01-12 14_40_36 r-Ag2 in p-0.5M_NaHCO3_pH=adj E = -0.4V pos=0,10 cw_1300.csv"
"C:\Users\jhemmer\Box\Johann Hemmer Data\Aq CO₂RR EC-SERS with r-Ag\2024\01 Jan\01122023\2024-01-12 14_57_41 r-Ag2 in p-0.5M_NaHCO3_pH=adj E = -0.6V pos=0,10 cw_1300.csv"
"C:\Users\jhemmer\Box\Johann Hemmer Data\Aq CO₂RR EC-SERS with r-Ag\2024\01 Jan\01122023\2024-01-12 15_14_27 r-Ag2 in p-0.5M_NaHCO3_pH=adj E = -0.8V pos=0,10 cw_1300.csv"
};

% Background, if exists
bkgPath = {
    
};

% Parameters
laserWavelength = 532;
% frameRange = {[1, 120]; [1, 120]}; % Range of frames to plot
% offset = [0];

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
    % y{i} = y{i} + offset(i);
end

[fig, ax] = plotXY(x, y, ... 
    'XLabel', 'Raman shift (cm^{−1})', ...
    'YLabel', 'Intensity (counts)', ...
    'XLim', [min(x{1}) max(x{1})], ...
    'AspectRatio', 2.4, ...
    'PlotWidth', 8, ...
    'LineWidth', 2, ...
    'FigureName', 'spectrum');

% legend(ax, ...
%     {'Covalent attachment'; 'Physisorption'}, ...
%     'Location', 'best')

legend(ax, ...
    {"-0.2";"-0.4";"-0.6";"-0.8";"-1.0"}, ...
    'Location', 'northeast')

%% Saving
savePath = createAnalysisFolder(dataPath{1}, expName);

saveAllFigs(savePath, 'fig', 'pdf', 'png')

% Copy files
copyFile(savePath, dataPath, bkgPath)

% Saving a report
saveReport(savePath)