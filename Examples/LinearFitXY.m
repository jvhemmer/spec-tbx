% LinearFitXY: Plot simple XY graph and fit the data using a linear model.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   30 Jun 2025
clear
close all
clc

%% BASIC PARAMETERS
% Experiment name (comment out or leave blank to use file name)
expName = 'Rough derivative peaks';

% Path to save data
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)"
};

x =  [25 30 35 40 45 50];
x = x + 273.15;
% x = 1./x;

y1 = [-0.2377 -0.2397 -0.2442 -0.2457 -0.2497 -0.2507];

%% MAIN 
% Plot
[fig, ax] = plotXY(x, y, ... 
    XLabel =        '1/{\itT} (K^{−1})', ...
    YLabel =        '{\itE}_{1/2} (V vs. Ag/AgCl)', ...
    YLim =          [], ...
    XLim =          [], ...
    YTick =         [], ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    FigureName =    'plot', ...
    LineStyle =     'none', ...
    Marker =        'o', ...
    MarkerEdgeColor=[0 0.4470 0.7410], ...
    MarkerFaceColor=[0 0.4470 0.7410], ...
    MinusSignOnAx = true ...
    );

p = polyfit(x, y, 1);

yFit = polyval(p, x);

% plotXY(x, yFit, Axes=ax)

hold on

plot(stretch(x, 1.1), yFit, '--', 'LineWidth', 2, 'Color', [0 0.4470 0.7410]);

% errorbar(x, y, stdy, 'LineStyle', 'none', 'LineWidth', 1.5, 'Color', [0.1 0.1 0.1])

uistack(ax.Children(end), 'up')

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)