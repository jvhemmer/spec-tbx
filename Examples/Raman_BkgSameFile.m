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
expName = 'E=0.5V (multistep, bkg corr fixed)';

% Path to data files (char separated by space, semicolor or new line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\09072024\2024-09-07 16_16_03 multistep cw=2000 red laser.csv"
};

frameRange = {[1681, 1980]};
bkgRange = [1 30];
% bkgRanges = {[1 30], [331 360], [661 690], [991 1020], [1321 1350], [1651 1680]};
bkgRanges = {[1 30], [331 360], [661 690], [991 1020], [1321 1350], [1651 1680]};

%% Execution
nFiles = length(dataPath);

% Reading data
wavelength = cell([nFiles 1]);
intensity = cell([nFiles 1]);
ramanShift = cell([nFiles 1]);
corrIntensity = cell([nFiles 1]);
avgIntensity = cell([nFiles 1]);
avgBkgIntensity = cell([nFiles 1]);

for i = 1:nFiles
    % Read files
    [wavelength{i}, intensity{i}] = readSpectra(dataPath{i});

    avgBkgIntensities = cell([length(bkgRanges) 1]);
    for j = 1:length(bkgRanges)
        avgBkgIntensities{j} = avgSpectra(intensity{i}, "FrameRange", bkgRanges{j});
    end

    % Convert the cell array to a matrix
    matrix = cell2mat(avgBkgIntensities);
    
    % Reshape the matrix so each row corresponds to an array
    matrix = reshape(matrix, length(avgBkgIntensities{1}), length(avgBkgIntensities));
    
    % Calculate the mean along the first dimension (across the arrays)
    avgBkgIntensity{i} = mean(matrix, 2);

    % Convert wavelength to Raman shift
    ramanShift{i} = wavelengthToRS(wavelength{i}, 636.49);

    % Average the intensity
    avgIntensity{i} = avgSpectra(intensity{i}, ...
        'FrameRange', frameRange{i});

    % Background subtraction
    corrIntensity{i} = avgIntensity{i} - avgBkgIntensity{i};
end

x = ramanShift;
y = corrIntensity;

[fig, ax] = plotXY(x{1}, y{1}, ...
    'XLabel', 'Raman shift (cm^{−1})', ...
    'YLabel', 'Intensity (counts)', ...
    'XLim', [1800 2400], ...
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

    % legend(ax, ...
    %     {'E = 0.15 V'; 'E = −0.50 V'}, ...
    %     'Location', 'best')
end

%% Saving
savePath = createAnalysisFolder(dataPath{1}, expName);

saveAllFigs(savePath, 'fig', 'pdf', 'png')
disp(['Done saving figures at ' savePath '.'])

% Copy files
copyFile(savePath, dataPath)

% Saving a report
saveReport(savePath)