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
expName = 'Isothermal SS currents avg all trials no error bar, with fit';

% Path to save data
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Temperature gradient effect on CO2RR\Revision 1\New or Edited Figures\3\Average SS of multiple trials"
};

% General parameters
saveToAnalysisFolder = true;

T = [25.01 27 30 32 35];

% y1 = readmatrix(dataPath{1});
% y2 = [-0.0080735 -0.013472 -0.017163 -0.017300 -0.018120];
% y3 = [-0.0038588 -0.004667 -0.005540 -0.007625 -0.008481];

% avg = ( y1 + y2 + y3 ) / 3;
% std = std([y1; y2; y3]);

% y = avg; % y-values will be the average

y = [
0.00135234
-0.00083086
-0.00225948
-0.0032561
-0.0036309
];

stdy = [
0.002950807
0.005145686
0.005836205
0.005042508
0.006193098
];

maxU =  [0, 2.24e-1, 3.36e-1, 3.86e-1, 4.45e-1];

%% MAIN 
% Plot
[fig, ax, lin] = plotXY(T, y, ... 
    XLabel =        '{\itT} (°C)', ...
    YLabel =        'Δ{\itj}_{SS} (mA cm^{−2})', ...
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
    MarkerEdgeColor=[0.9 0.18 0.1], ...
    MarkerFaceColor=[0.9 0.18 0.1] ...
    );

ax.YDir = 'reverse';
ax.YAxis.Color = [0.9 0.18 0.1];

hold on

% errorbar(x, y, stdy, 'LineStyle', 'none', 'LineWidth', 1.5, 'Color', [0.1 0.1 0.1])

uistack(ax.Children(end), 'up')

yyaxis(ax, 'right')
plot(T, maxU, Color=[0.24 0.51 0.07], LineStyle='none', LineWidth=1.5, Marker="o", MarkerFaceColor=[0.24 0.51 0.07])
ylim([-0.05 0.49])
yticks(0:0.1:0.5)
% ylim([-0.3 1])
% yticks(-0.2:0.2:1)
ax.YAxis(2).Color = [0.24 0.51 0.07];
ylabel(ax, '{\itu}_{max} (mm/s)')

% uistack(ax.Children(end), 'down')

% l = legend(ax, '', 'Experimental Δ{\itj}_{SS}', 'Simulated {\itu}_{max}', Location='northwest')
l = legend(ax, 'Experimental Δ{\itj}_{SS}', 'Simulated {\itu}_{max}', Location='southeast');
l.AutoUpdate = false;

% Fit maxU vs T to a power law model y = a*x^(1/n)
fitType = fittype('a*x^(1/n)', 'independent', 'x');
fitType2 = fittype('a*x^(1/n) + b', 'independent', 'x');
[UFitResult, u_gof] = fit((T-25)', maxU', fitType, StartPoint=[0.05 2]);
[jssFitResult, jss_gof] = fit((T-25)', y, fitType2, StartPoint=[0.001 2 1]);

% Generate fitted values for plotting
T_fit = linspace(min(T-25), max(T-25), 100);
jss_fit = feval(jssFitResult, T_fit);
maxU_fit = feval(UFitResult, T_fit);

plot(T_fit+25, maxU_fit, Color=[0.24 0.51 0.07], LineStyle='--', LineWidth=1.5)

yyaxis(ax, 'left')

plot(T_fit+25, jss_fit, Color=[0.9 0.18 0.1], LineStyle='--', LineWidth=1.5)

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