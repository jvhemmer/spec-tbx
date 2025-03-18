% LSV_SurfaceCoverage: Integrate area under a peak during LSV and 
% calculate surface coverage.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   8 Feb 2025
clear
close all
clc

%% BASIC PARAMETERS
% Experiment name (comment out or leave blank to use file name)
expName = 'E2 desorption (fixed, vs time)';

% Path to data file
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\02212025\E2 desorption.txt"
};

% Parameters
scanRate = 0.1; % V/s
electrodeDiameter = 0.2; % cm
geometricArea = pi * electrodeDiameter^2 / 4;
electrodeArea = geometricArea;
n = 1; % stoichiometric number of electrons tranfered
F = 96485; % Faraday's constant in C/mol
integrationRange = [8.16 10.88];

% Plotting options
YScaleFactor = 1e3;

%% MAIN
% Read file
[potential, current] = readData(dataPath{1}, 1, 2);

% Calculate current density
curDensity = current / electrodeArea;

% Get time from CV/LSV
time = timeFromCV(potential, scanRate);

% Integrate area under curve to get charge
charge = integratePeak(time, current, integrationRange, debug=true);

% Account for negative peaks
charge = abs(charge);

coverage = charge/(n * F * electrodeArea);

% Plot potential vs. current
[fig, ax] = plotXY(potential, curDensity, ... 
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', '{\itj} (mA cm^{−2})', ...
    'YLim', [], ...
    'XLim', [], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'FigureName', 'LSV', ...
    'YScaleFactor', YScaleFactor);

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveAllFigs(savePath, "fig", "png", "pdf")

% Save coverage
saveTable(charge, coverage, ...
    VariableNames = {'Q (C)'; 'Γ (mol/cm^2)'}, ...
    SavePath = savePath ...
    )

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)
