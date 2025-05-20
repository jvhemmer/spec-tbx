% simulation_T_gradient: Plot simulated temperature gradient data obtained
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
expName = 'temperature gradient (Horiz plate) r=1 all depths';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\New simulations\Horizontal Plate\T Gradient T=35 z=0 r=1.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\New simulations\Horizontal Plate\T Gradient T=35 z=4 r=1.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\New simulations\Horizontal Plate\T Gradient T=35 z=10 r=1.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\New simulations\Horizontal Plate\T Gradient T=35 z=14 r=1.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\New simulations\Horizontal Plate\T Gradient T=35 z=18 r=1.txt"
};

% Plotting options
YScaleFactor = 1;
% colors = {
%     [0.0 0 0];
%     [0.3 0 0];
%     [0.6 0 0];
%     [0.9 0 0];
%     [1.0 0 0]
%     };

% Temperature gradient colors
colors = {
    [0.10 0.10 0.10]        % dark grey
    [0.45 0.00 0.00]        % 
    [0.90 0.00 0.00]        %
    [0.95 0.50 0.50]
    [1.00 0.70 0.70]
};

%% MAIN 
nFiles = length(dataPath); % number of files

z = cell([nFiles 1]); % preallocate arrays
T = cell([nFiles 1]);

for i = 1:nFiles % read all data files
    [z{i}, T{i}] = readData(dataPath{i}, 1, 2);
end

% Plot first file
[fig, ax] = plotXY(z, T, ... 
    XLabel =        '{\ity} (mm)', ...
    YLabel =        '{\itT} (°C)', ...
    YLim =          [24 36], ...
    XLim =          [0 4], ...
    XTick =         [0:0.5:4], ...
    YTick =         [25:2:35], ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    LineWidth =     1.5, ...
    FigureName =    'temperature_gradient', ...
    YScaleFactor =  YScaleFactor, ...
    Color =         colors ...
    );

legend(ax, ...
    label = {'0'; '4'; '10'; '14'; '18'}, ...
    Location = 'best')

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)
