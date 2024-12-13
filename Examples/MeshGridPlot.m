% Plot explicit functions using a mesh grid.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   18 Nov 2024
clear
close
clc

%% Basic Parameters
% Experiment name (comment out or leave blank to use file name)
path = "C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\12012024";
expName = "Nernst Simulation";


T_range = [25 30 35] + 273.15;

n = 2;
F = 96485;
R = 8.314;
E0 = -0.267;

func = @(E, T) (exp(n * F * (E - E0)) / (R * T));

E = -0.6:0.001:0;

[E_grid, T_grid] = meshgrid(E, T_range);
ratio = exp(n * F * (E_grid - E0) ./ (R * T_grid) );
fracO = ratio ./ (1 + ratio);

fracO = mat2cell(fracO, ones(1, length(T_range)), length(E));

[fig, ax] = plotXY(E, fracO, ...
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', 'fraction of O', ...
    'XLim', [-0.6 0], ...
    'YLim', [-0.1 1.1], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'Interpreter', 'tex', ...
    'LineWidth', 1.5, ...
    'LineStyle', '-');

legend(ax, ...
    {'25 °C'; '30 °C'; '35 °C'}, ...
    'Location', 'southeast')

% Creating folder to save analysis
savePath = createAnalysisFolder(path + filesep + expName, expName);

% Saving figures
saveFig(fig, 'output', savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)