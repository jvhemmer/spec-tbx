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
% Path to save
dataPath = "C:\Users\jhemmer\Box\Johann Hemmer Data\Plasmon-induced migration (Amin 3rd project)\Manuscript Figures\4";

% Experiment name (comment out or leave blank to use file name)
expName = 'j_plasmon and E-field vs I0 fit, exp linear fit';

% General parameters
saveToAnalysisFolder = true;

% Data
I0 = [0 0.64 0.96 1.27 1.59 2.38];

j1 = [0 6.28E-02 8.02E-02 1.07E-01 1.14E-01 1.71E-01];
j2 = [0 -2.27E-02 -5.12E-03 9.80E-03 4.15E-03 1.91E-02];

j1_error = [0 0.027521574 0.014192672 0.017448462 0.015557465 0.02641543];
j2_error = [0 0.019926194 0.007629539 0.009119152 0.021396582 0.014268428];

E1 = [0 26191 32077 36894 41282 50507]./1e3;
E2 = [0 13997 17143 19717 22062 26992]./1e3;

%% MAIN 
% Plot
fig = figure('Theme', 'light', 'Name', 'plot', 'Units', 'inches');
ax = axes(fig, 'Units', 'inches');

set(ax, FontSize = 18, FontName = 'Arial', LineWidth = 2)
box on
xlabel(ax, '{\itI}_0 (W cm^{−2})')
ylabel(ax, '{\itj}_{plasmon} − {\itj}_{thermal} (mA cm^{−2})')

xlim([-0.05 2.5])

% Change decimal places of the axes
xtickformat('%.1f')
ytickformat('%.2f')

hold on

p1 = errorbar(ax, I0, j1, j1_error, 'o', ...
    Color = [0.00 0.50 0.00], ...
    LineStyle = 'none', ...
    LineWidth = 2);

p2 = errorbar(ax, I0, j2, j2_error, 'square', ...
    Color = [0, 0.4470, 0.7410], ...
    LineStyle = 'none', ...
    LineWidth = 2);

yyaxis('right')

i1 = scatter(ax, I0, E1, ...
    LineWidth = 2, ...
    MarkerEdgeColor = [0.00 0.50 0.00], ...
    MarkerFaceColor = [0.00 0.50 0.00], ...
    Marker = 'o');

i2 = scatter(ax, I0, E2, ...
    LineWidth = 2, ...
    MarkerEdgeColor = [0, 0.4470, 0.7410], ...
    MarkerFaceColor = [0, 0.4470, 0.7410], ...
    Marker = 'square');

ax.YAxis(2).Color = [0.1 0.1 0.1];

ylabel(ax, '|{\bfE}| (kV/m)'); % Label for right y-axis

ylim([0 70])

leg1 = legend(ax, [p1 p2], '532 nm', '473 nm', 'Location', 'northwest');
% leg2 = legend(ax, [i1 i2], '532 nm', '473 nm', 'Location', 'west'); % Matlab doesn't like this

% Adjust size
AspectRatio = 1.2;
PlotWidth = 5;
PlotHeight = PlotWidth / AspectRatio;
ax.Position([3 4]) = [PlotWidth PlotHeight];
fig.Position([3 4]) = ax.OuterPosition([3 4]);
ax.OuterPosition(1) = ax.OuterPosition(1) + ax.TickLength(1);
fig.Position(3) = fig.Position(3);

% Fit simulation
fitType = fittype('a*x^(1/n)', 'independent', 'x');
% fitType2 = fittype('a*x^(1/n) + b', 'independent', 'x');
[fitResult1, gof1] = fit((I0)', E1', fitType, StartPoint=[0.05 2]);
[fitResult2, gof2] = fit((I0)', E2', fitType, StartPoint=[0.05 2]);

% Generate fitted values for plotting
x_fit = linspace(min(I0), max(I0), 100);
E1_fit = feval(fitResult1, x_fit);
E2_fit = feval(fitResult2, x_fit);

plot(x_fit, E1_fit, Color=[0.00 0.50 0.00], LineStyle='--', LineWidth=2)
plot(x_fit, E2_fit, Color=[0, 0.4470, 0.7410], LineStyle='--', LineWidth=2)

% Fit experimental data
% fitTypeExp = fittype('a*x^(1/n) + b', 'independent', 'x');
fitTypeExp = fittype('m*x + b', 'independent', 'x');
[fitResult532Exp, gof532Exp] = fit((I0)', j1', fitTypeExp, StartPoint=[0.01 0]);
[fitResult473Exp, gof473Exp] = fit((I0)', j2', fitTypeExp, StartPoint=[0.01 0]);

% Generate fitted values for plotting
j532Fit = feval(fitResult532Exp, x_fit);
j473Fit = feval(fitResult473Exp, x_fit);

yyaxis('left')

plot(x_fit, j532Fit, Color=[0.00 0.50 0.00], LineWidth=2, Marker='none', LineStyle='-')
plot(x_fit, j473Fit, Color=[0, 0.4470, 0.7410], LineWidth=2, Marker='none', LineStyle='-')

% Creating folder to save analysis
if saveToAnalysisFolder == true
    % Creating folder to save analysis
    savePath = createAnalysisFolder(dataPath{1}, expName);

    % Copy files
    if isfile(dataPath{1})
        copyFile(savePath, dataPath)
    end
else
    savePath = fileparts(dataPath{1});
end

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)