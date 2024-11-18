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
path = "C:\Users\jhemmer\OneDrive - University of Louisville\6. Fall 2024\CHEM620";
expName = "Poisson graph";

N = 1.2;

func = @(n) ( (N^n) * exp(-N) ) / ( gamma(n+1) );

x = 0:0.1:10;
y = arrayfun(func, x);

[fig, ax] = plotXY(x, y, ...
    'XLabel', '$n$', ...
    'YLabel', '$P(n,N)$', ...
    'XLim', [], ...
    'YLim', [], ...
    'AspectRatio', 2, ...
    'PlotWidth', 5, ...
    'Interpreter', 'latex', ...
    'LineWidth', 1.5, ...
    'LineStyle', '--');

x2 = 0:1:10;
y2 = arrayfun(func, x2);

hold on
scatter(ax, x2, y2, ...
    'MarkerEdgeColor', [0.0000 0.4470 0.7410], ...
    'MarkerFaceColor', [1 1 1], ...
    'LineWidth', 1.5)
    
% if nFiles > 1
%     for j = 2:nFiles
%     plotXY(potential{j}, current{j}, ...
%         'YScaleFactor', YScaleFactor, ...
%         'Color', j, ...
%         'Axes', ax);
%     end
% end

% legend(ax, ...
%     {'Continuous'; 'Discrete'}, ...
%     'Location', 'best')

% Creating folder to save analysis
savePath = createAnalysisFolder(path + filesep + expName, expName);

% Saving figures
saveFig(fig, 'output', savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)