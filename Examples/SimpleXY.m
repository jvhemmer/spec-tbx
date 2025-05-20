% SimpleXY: Plot simple XY graph.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   1 May 2025
clear
close all
clc

%% BASIC PARAMETERS
% Experiment name (comment out or leave blank to use file name)
expName = 'SS current average (1st trial only)';

% Path to save data
dataPath = {
    "C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Data from Amin\CA Heating surface"
    };

% Path to data files (one per line)
x =  [25 27 30 32 35];

y1 = [-0.0078209 -0.012797 -0.014446 -0.015303 -0.016024];
% y2 = [-0.0080735 -0.013472 -0.017163 -0.017300 -0.018120];
% y3 = [-0.0038588 -0.004667 -0.005540 -0.007625 -0.008481];

% avg = ( y1 + y2 + y3 ) / 3;
% std = std([y1; y2; y3]);

% y = avg; % y-values will be the average

%% MAIN 
% Plot
[fig, ax] = plotXY(x, y, ... 
    XLabel =        '{\itT} (°C)', ...
    YLabel =        '{\itj}_{SS} (mA cm^{−2})', ...
    YLim =          [-17.5 -7], ...
    XLim =          [24 36], ...
    XTick =         [25:2:35], ...
    YTick =         [], ...
    LineWidth =     1.5, ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    FigureName =    'plot', ...
    LineStyle =     'none', ...
    Marker =        'o', ...
    MarkerEdgeColor=[0.9000 0.3250 0.0980], ...
    MarkerFaceColor=[0.9000 0.3250 0.0980], ...
    MinusSignOnAx = true ...
    );

ax.YDir = 'reverse';

hold on

% errorbar(x, y, stdy, 'LineStyle', 'none', 'LineWidth', 1.5, 'Color', [0.1 0.1 0.1])

% uistack(ax.Children(end), 'up')

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)