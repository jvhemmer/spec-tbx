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
expName = 'Oxidized vs. Reduced Spectra';

% Path to data files (char separated by space, semicolor or new line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\01. EC-SERS\Data\Nile Blue Activation Energy\08182024\2024-08-18 18_10_05 CV_0p2_to_-0p6V 5mVps r-Ag 1 25C.csv" 
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\01. EC-SERS\Data\Nile Blue Activation Energy\08182024\2024-08-18 18_10_05 CV_0p2_to_-0p6V 5mVps r-Ag 1 25C.csv"
};

bkgPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\01. EC-SERS\Data\Nile Blue Activation Energy\08132024\2024-08-13 13_36_03 DC.csv"
};

frameRange = {[1, 20], [171, 190]};

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
    ramanShift{i} = wavelengthToRS(wavelength{i}, 636.49);

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
    'YLim', [-1e3 21e3], ...
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
        {'E = 0.15 V'; 'E = −0.50 V'}, ...
        'Location', 'best')
end

%% Saving
savePath = createAnalysisFolder(dataPath{1}, expName);

saveAllFigs(savePath, 'fig', 'pdf', 'png')
disp(['Done saving figures at ' savePath '.'])

% Saving the areas
% saveTable(peakPos, peakArea, ... 
%     'SavePath', savePath, ...
%     'VariableNames', {'Peak Raman Shift (cm-1)', 'Area'}, ...
%     'FileName', 'areas.txt');

% Copy files
copyFile(savePath, dataPath, bkgPath)

% Saving a report
saveReport(savePath)