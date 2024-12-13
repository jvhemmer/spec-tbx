% Plot explicit functions in the form of f = y(x)
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

E = -0.6:0.1:0;

ratio = cell([length(T_range) 1]);
fracO = cell([length(T_range) 1]);
for i = 1:length(T_range)
    ratio{i} = arrayfun(func, E, T_range(i));
    fracO{i} = (ratio{i} / (1 + ratio{i}));
end

[fig, ax] = plotXY(E, fracO, ...
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', '{\itx}_O', ...
    'XLim', [-0.6 0], ...
    'YLim', [0 1], ...
    'AspectRatio', 2, ...
    'PlotWidth', 5, ...
    'Interpreter', 'tex', ...
    'LineWidth', 1.5, ...
    'LineStyle', '-');

% legend(ax, ...
%     {'Continuous'; 'Discrete'}, ...
%     'Location', 'best')

% Creating folder to save analysis
savePath = createAnalysisFolder(path + filesep + expName, expName);

% Saving figures
saveFig(fig, 'output', savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)