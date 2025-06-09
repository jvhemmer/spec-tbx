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
expName = 'SS current 1';

% Path to save data
dataPath = {
    "C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Data from Amin\ES CA Surafce"
    };

% Path to data files (one per line)
x =  [25 27 30 32 35];
y =  1e3*[-0.0078209 -0.012797 -0.014446 -0.015303 -0.016024];

%% MAIN 
% Plot
[fig, ax] = plotXY(x, y, ... 
    XLabel =        '{\itT} (°C)', ...
    YLabel =        '{\itj}_{SS} (mA cm^{−2})', ...
    YLim =          [], ...
    XLim =          [24 36], ...
    XTick =         [25:2:35], ...
    YTick =         [], ...
    LineWidth =     1.5, ...
    NumSize =       16, ...
    FontSize =      18, ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    FigureName =    'max velocity vs. temperature', ...
    LineStyle =     'none', ...
    Marker =        'none', ...
    MinusSignOnAx = true ...
    );

ax.YDir = 'reverse';

% Color for the non-isothermal (gradient)
colors = {
    [0.1000 0.1000 0.1000]      % dark grey
    [0.4660 0.6740 0.1880]      % green
    [0.8290 0.6940 0.1250]      % burnt yellow
    [0.8000 0.3250 0.0980]      % orange-brown
    [0.9000 0.0000 0.0000]      % strong red
};

hold on

for i = 1:length(x)
    plot(ax, x(i), y(i), ...
        LineStyle='none', ...
        Marker='o', ...
        MarkerEdgeColor=colors{i}, ...
        MarkerFaceColor=colors{i}, ...
        LineWidth=1.5)
end

hold off

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)