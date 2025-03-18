% simulation_vel_gradient: Plot simulated velocity gradient data obtained
% from COMSOL.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   2 Feb 2025
clear
close all
clc

%% BASIC PARAMETERS
% Experiment name (comment out or leave blank to use file name)
expName = 'max velocity vs. temperature';

% Path to save data
dataPath = {
    "C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper"
    };

% Path to data files (one per line)
maxU =  [0      2.24e-1     3.36e-1     3.86e-1     4.45e-1];
T =     [25     27          30          32          35];

% Plotting options
YScaleFactor = 1;

%% MAIN 
% Plot
[fig, ax] = plotXY(T, maxU, ... 
    XLabel =        '{\itT} (°C)', ...
    YLabel =        '{\itu}_{max} (mm/s)', ...
    YLim =          [-0.01 0.5], ...
    XLim =          [24 36], ...
    XTick =         [25:2:35], ...
    YTick =         [], ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    FigureName =    'max velocity vs. temperature', ...
    YScaleFactor =  YScaleFactor, ...
    LineStyle =     'none', ...
    Marker =        'o' ...
    );

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)