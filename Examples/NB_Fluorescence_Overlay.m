% Data processing for Nile Blue activation energy using fluorescence from
% the camera without a spectrometer.
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
expName = 'Rough Trial 1 normalized';

% Path to data files (char separated by space, semicolor or new line)
sersPath = { % optical data
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 14_47_50 LSV_5mVps 10uW_laser rough 24.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 18_56_20 LSV_5mVps 10uW_laser rough 1 30.5C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 19_48_05 LSV_5mVps 10uW_laser rough 1 35.5C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 16_04_32 LSV_5mVps 10uW_laser rough 1 40.2C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 20_31_00 LSV_5mVps 10uW_laser rough 1 45.9C.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 17_00_53 LSV_5mVps 10uW_laser rough 1 49.5C.csv"
};

bkgPath = { % SERS background spectra
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\2025-04-20 21_02_49 DC AG=HIGH.csv"
};

% Experiment parameters
fps = 10; % frames per second (from LightField)
scanRate = 0.005; % V/s
% CVlimits = [-40 -30];
ROI = {1:70, 1:70}; % region in the image that will be binned
normFactor = [11002100 8975400 8049680 8517930 6536980 7233460];

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

% Process background spectrum
if not(isempty(bkgPath))
    [~, bkgImage] = readCameraMatrix(bkgPath);

    bkgIntensity = zeros([length(bkgImage{1}) 1]);
    for j = 1:length(bkgIntensity)
        bkgIntensity(j) = sum(bkgImage{j}(ROI{1},ROI{2}), "all");
    end

    % Subtract background for each
    for i = 1:length(sersPath)
        intensity{i} = intensity{i} - mean(bkgIntensity);
    end
end

% % Normalization
% for i = 1:length(intensity)
%     intensity{i} = intensity{i} ./ normFactor(i);
% end

%% Plotting
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
    'FigureName', 'potential_vs_der', ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'Color', SpecTbxColors.Heat);


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