% Overlay_MulticolumnTXT: Plot XY graph in overlay format from a single
% file containing multiple datasets separated by columns.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   5 May 2025
clear
close all
clc

%% BASIC PARAMETERS
% Experiment name (comment out or leave blank to use file name)
expName = 'velocity gradient (new)';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\New simulations\L-shaped\Velocity away for electrode (L-shaped electrode).txt"
};

% Plotting options
YScaleFactor = 1;

% Non-isothermal colors
colors = {
    [0.1000 0.1000 0.1000]      % dark grey
    [0.4660 0.6740 0.1880]      % green
    [0.8290 0.6940 0.1250]      % burnt yellow
    [0.8000 0.3250 0.0980]      % orange-brown
    [0.9000 0.0000 0.0000]      % strong red
};

%% MAIN 
nFiles = length(dataPath); % number of files

z = cell([nFiles 1]); % preallocate arrays
u = cell([nFiles 1]);
maxU = zeros([nFiles 1]);
maxZ = zeros([nFiles 1]);

for i = 1:nFiles % read all data files
    [z{i}, u{i}] = readData(dataPath{i}, 1, 2);

    [maxU(i), idx] = max(u{i});
    maxZ(i) = z{i}(idx);
end

% Plot first file
[fig, ax] = plotXY(z, u, ... 
    XLabel =        '{\itz} (mm)', ...
    YLabel =        '{\itu} (mm/s)', ...
    YLim =          [-0.01 0.5], ...
    XLim =          [0 8], ...
    XTick =         [], ...
    YTick =         [], ...
    LineWidth =     1.5, ...
    NumSize =       16, ...
    FontSize =      18, ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    FigureName =    'velocity_gradient', ...
    YScaleFactor =  YScaleFactor, ...
    Color =         colors ...
    );

legend(ax, ...
    label = {'25.0'; '27.0'; '30.0'; '32.0'; '35.0'}, ...
    Location = 'best')

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Saving variables
varsToExport = {"maxU"; "maxZ"};
for i = 1:length(varsToExport)
    save( ...
        strcat(savePath, filesep, varsToExport{i}, ".txt"), ...
        varsToExport{i}, ...
        "-ascii" ...
        )
end

% Copy files
copyFile(savePath, dataPath)
