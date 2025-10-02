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
expName = 'SS currents avg all trials';

% Path to save data
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Temperature gradient effect on CO2RR\Revision 1\New or Edited Figures\3\Average SS of multiple trials"
};

% General parameters
saveToAnalysisFolder = true;

x =  [25 27 30 32 35];

% y1 = readmatrix(dataPath{1});
% y2 = [-0.0080735 -0.013472 -0.017163 -0.017300 -0.018120];
% y3 = [-0.0038588 -0.004667 -0.005540 -0.007625 -0.008481];

% avg = ( y1 + y2 + y3 ) / 3;
% std = std([y1; y2; y3]);

% y = avg; % y-values will be the average

y = [
-0.005966475
-0.00893115
-0.01105375
-0.012363725
-0.01385735
];

stdy = [
0.002291813
0.00486168
0.00563126
0.004665489
0.005380317
];

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

errorbar(x, y, stdy, 'LineStyle', 'none', 'LineWidth', 1.5, 'Color', [0.1 0.1 0.1])

uistack(ax.Children(end), 'up')

% Creating folder to save analysis
if saveToAnalysisFolder == true
    % Creating folder to save analysis
    savePath = createAnalysisFolder(dataPath{1}, expName);

    % Copy files
    copyFile(savePath, dataPath)
else
    savePath = fileparts(dataPath{1});
end

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)