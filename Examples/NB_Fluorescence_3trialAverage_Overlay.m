% Data processing for Nile Blue activation energy using fluorescence from
% the camera without a spectrometer. Makes average of 3 trials for each
% condition
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   For documentation, see: github.com/jvhemmer/spec-tbx/
%   johann.hemmer@louisville.edu
%   28 Apr 2025
clear
close all
clc

%% Basic Parameters
% Experiment name (leave blank to use file name).
expName = 'Intensity only all temps normalized (avg of 3 trials) - smooth';

% Path to data files (char separated by space, semicolor or new line)
sersPath = { % optical data
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 15_14_05 LSV_5mVps 10uW_laser smooth 1 26.1C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 15_08_58 LSV_5mVps 10uW_laser smooth 1 25.2C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 15_03_00 LSV_5mVps 10uW_laser smooth 1 25.3C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 19_24_59 LSV_5mVps 10uW_laser smooth 3 30.7C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 19_18_45 LSV_5mVps 10uW_laser smooth 2 30.5C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 19_13_03 LSV_5mVps 10uW_laser smooth 1 30.2C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 20_15_37 LSV_5mVps 10uW_laser smooth 3 34.9C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 20_10_18 LSV_5mVps 10uW_laser smooth 2 35.3C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 20_04_31 LSV_5mVps 10uW_laser smooth 1 35.3C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 16_33_53 LSV_5mVps 10uW_laser smooth 3 40.1C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 16_28_04 LSV_5mVps 10uW_laser smooth 2 40.3C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 16_22_39 LSV_5mVps 10uW_laser smooth 1 39.8C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 20_58_57 LSV_5mVps 10uW_laser smooth 3 44.5C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 20_53_31 LSV_5mVps 10uW_laser smooth 2 44.6C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 20_47_16 LSV_5mVps 10uW_laser smooth 1 44.5C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 17_30_51 LSV_5mVps 10uW_laser smooth 3 49.4C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 17_21_05 LSV_5mVps 10uW_laser smooth 2 49.9C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 17_13_43 LSV_5mVps 10uW_laser smooth 1 49.9C.csv"
};

bkgPath = { % SERS background spectra
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\2025-04-20 21_02_49 DC AG=HIGH.csv"
};

% Experiment parameters
fps = 10; % frames per second (from LightField)
scanRate = 0.005; % V/s
% CVlimits = [-40 -30];
ROI = {1:70, 1:70}; % region in the image that will be binned
nTrials = 3;
normFactor = [7849220 7388020 7220940 6622480 6237880 5793120];

%% Execution
% Read the data contained in the file
for i = 1:length(sersPath)
    [frame{i}, image{i}] = readCameraMatrix(sersPath{i});
end
frame = frame{1};

intensity = cell([length(sersPath) 1]);
for i = 1:length(sersPath)
    intensity{i} = zeros([length(image{i}{1}) 1]);
    for j = 1:length(frame)
        intensity{i}(j) = sum(image{i}{j}(ROI{1},ROI{2}), "all");
    end
end

intensities = intensity; % Save original calculated intensities

% Average of multiple trials
averageIntensity = cell([nTrials 1]);
combinedIntensity = zeros([length(intensity{1}) 1]);

if mod(length(sersPath), nTrials) ~= 0
    error("Numbers of files is not a multiple of the number of trials.")
end

for i = 1:length(sersPath)
    trial = ceil(i/nTrials);
    combinedIntensity = combinedIntensity + intensity{i};
    if mod(i,nTrials) == 0
        averageIntensity{trial} = combinedIntensity / nTrials;
        combinedIntensity = zeros([length(intensity{1}) 1]);
    end
end

intensity = averageIntensity;

% Process background spectrum
if not(isempty(bkgPath))
    [~, bkgImage] = readCameraMatrix(bkgPath);

    bkgIntensity = zeros([length(bkgImage{1}) 1]);
    for j = 1:length(bkgIntensity)
        bkgIntensity(j) = sum(bkgImage{j}(ROI{1},ROI{2}), "all");
    end

    % Subtract background for each
    for i = 1:length(intensity)
        intensity{i} = intensity{i} - mean(bkgIntensity);
    end
end

% Normalization
for i = 1:length(intensity)
    intensity{i} = intensity{i} ./ normFactor(i);
end

% Plot Intensity vs potential
[potential, time] = calculateWaveform(0, -0.6, fps, scanRate, 1);

[fig, ax] = plotXY(potential, intensity, ...
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', '{\itI}', ...
    'FigureName', 'potential_vs_area', ...
    'YLim', [], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'Color', SpecTbx.Colors.Heat);

% Plotting dI/dt vs potential

% Calculate the smooth intensity 
smoothIntensity = cellfun(@(cel) mirroredSGolayFilt(cel, 3, 233), intensity, 'UniformOutput', false);

% Calculate derivative
der = cellfun(@(cel) diff(cel)./diff(time), smoothIntensity, 'UniformOutput', false);

[fig3, ax3] = plotXY(potential(1:end-1), der, ...
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', 'd{\itI}/d{\itt}', ...
    'YExponent', -2, ...
    'FigureName', 'potential_vs_der', ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'Color', SpecTbx.Colors.Heat);


%% Saving
savePath = createAnalysisFolder(sersPath{1}, expName);

saveAllFigs(savePath, 'fig', 'png', 'pdf')
disp(['Done saving figures at ' savePath '.'])

% Saving the areas
cellfun( ...
    @(cel) saveTable(potential', cel, ... 
    'SavePath', savePath, ...
    'VariableNames', {'Potential (V)', 'Intensity'}, ...
    'FileName', 'areas.txt'), ...
    intensity, 'UniformOutput', false);


% Copy files
copyFile(savePath, sersPath, bkgPath)

% Saving a report
saveReport(savePath)