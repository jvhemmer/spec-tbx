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
expName = 'Intensity only all temps';

% Path to data files (char separated by space, semicolor or new line)
sersPath = { % optical data
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E12 (same as E10, E8), rough, 1uM NB soln\2025-04-20 11_21_13 LSV_5mVps 10uW_laser 25.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E12 (same as E10, E8), rough, 1uM NB soln\2025-04-20 12_17_41 LSV_5mVps 10uW_laser 29.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E12 (same as E10, E8), rough, 1uM NB soln\2025-04-20 12_40_07 LSV_5mVps 10uW_laser 35.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E12 (same as E10, E8), rough, 1uM NB soln\2025-04-20 13_42_41 LSV_5mVps 10uW_laser 39.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E12 (same as E10, E8), rough, 1uM NB soln\2025-04-20 11_47_47 LSV_5mVps 10uW_laser 44.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E12 (same as E10, E8), rough, 1uM NB soln\2025-04-20 13_04_51 LSV_5mVps 10uW_laser 49.csv"
};

bkgPath = { % SERS background spectra
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\2025-04-20 21_02_49 DC AG=HIGH.csv"
};

% Experiment parameters
fps = 10; % frames per second (from LightField)
scanRate = 0.005; % V/s
% CVlimits = [-40 -30];
ROI = {1:70, 1:70}; % region in the image that will be binned

% Colors
colors = {
    [0.1000 0.1000 0.1000]      % dark grey
    [0.0000 0.4470 0.7410]      % blue
    [0.4660 0.6740 0.1880]      % green
    [0.8290 0.6940 0.1250]      % burnt yellow
    [0.8000 0.3250 0.0980]      % orange-brown
    [0.9000 0.0000 0.0000]      % strong red
};

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

% intensities = intensity; % Save original calculated intensities
% 
% % Average of multiple trials, if more than one file was input
% combinedIntensity = zeros([length(intensity{1}) 1]);
% for i = 1:length(sersPath)
%     combinedIntensity = combinedIntensity + intensity{i};
% end
% 
% averageIntensity = combinedIntensity / length(sersPath);

% intensity = averageIntensity;

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

% Plot Intensity vs potential
[potential, time] = calculateWaveform(0, -0.6, fps, scanRate, 1);

[fig, ax] = plotXY(potential, intensity, ...
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', '{\itI}', ...
    'FigureName', 'potential_vs_area', ...
    'YLim', [], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'Color', 'heat');

% Plotting dI/dt vs potential

% Calculate the smooth intensity 
smoothIntensity = cellfun(@(cel) mirroredSGolayFilt(cel, 3, 233), intensity, 'UniformOutput', false);

% Calculate derivative
der = cellfun(@(cel) diff(cel)./diff(time), smoothIntensity, 'UniformOutput', false);

[fig3, ax3] = plotXY(potential(1:end-1), der, ...
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', 'd{\itI}/d{\itt}', ...
    'YExponent', 3, ...
    'FigureName', 'potential_vs_der', ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'Color', 'heat');


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