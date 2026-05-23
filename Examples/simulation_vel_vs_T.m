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
};

% Path to data files (one per line)
maxU =  [0, 2.24e-1, 3.36e-1, 3.86e-1, 4.45e-1, 5.18e-1, 6.28e-1, 8.11e-1];
T =     [25, 27, 30, 32, 35, 40, 50, 75];

% Plotting options
YScaleFactor = 1;

%% MAIN 
% Plot
[fig, ax] = plotXY(T, maxU, ... 
    XLabel =        '{\itT} (°C)', ...
    YLabel =        '{\itu}_{max} (mm/s)', ...
    YLim =          [-0.05 0.85], ...
    XLim =          [24 76], ...
    XTick =         [25:5:75], ...
    YTick =         [], ...
    LineWidth =     1.5, ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    FigureName =    'max velocity vs. temperature', ...
    YScaleFactor =  YScaleFactor, ...
    LineStyle =     'none', ...
    Marker =        'o', ...
    MarkerEdgeColor=[0.0000 0.4470 0.7410], ...
    MarkerFaceColor=[0.0000 0.4470 0.7410] ...
    );

% Fit maxU vs T to a square-root model y = a*x^(1/2)
fitType = fittype('a*x^(1/2)', 'independent', 'x');
fitResult = fit((T-25)', maxU', fitType, StartPoint=0.01);

% Generate fitted values for plotting
T_fit = linspace(min(T-25), max(T-25), 100);
maxU_fit = feval(fitResult, T_fit);

% Plot the fitted curve
hold(ax, 'on');
plot(ax, T_fit+25, maxU_fit, 'k:', 'LineWidth', 1.5);
hold(ax, 'off');

% Fit maxU vs T to a power law model y = a*x^(1/n)
fitType2 = fittype('a*x^(1/n)', 'independent', 'x');
fitResult2 = fit((T-25)', maxU', fitType2, StartPoint=[0.01 1]);

% Generate fitted values for plotting
maxU_fit2 = feval(fitResult2, T_fit);

% Plot the fitted curve
hold(ax, 'on');
plot(ax, T_fit+25, maxU_fit2, 'k--', 'LineWidth', 1.5);
hold(ax, 'off');

% Add legend entry for the fitted curve
legend(ax, 'Simulated {\itu}_{max}', 'Fit to {\ity = ax}^{1/2}', 'Fit to {\ity = ax}^{1/{\itn}}', 'Location', 'Best');

uistack(ax.Children(end), 'top')

% Creating folder to save analysis
% savePath = createAnalysisFolder(dataPath{1}, expName);
savePath = "C:\Users\jhemmer\Box\Johann Hemmer Data\Temperature Gradient on CO2RR (Amin 2nd Project)\2025\08 Aug\20250813\Vel vs T new and old temperatures";

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Save workspace
save(append(savePath, filesep, 'workspace.mat'))