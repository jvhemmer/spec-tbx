% BarPlot_StackedSideBySide: Plot bar plots that contain both stacked and
% side-by-side (grouped) data in the same axes.
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
expName = 'NumMols BarPlot all conditions STACKED (thinner)';

% Path to save data
dataPath = {
    "C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Data from Amin"
    };

% Data
x = ["25" "27" "30" "32" "35"];

% CO Non-isothermal data
% CO_NI = [28 46.394 58.358 54.31 55.14]; 
% CO_STD_NI = [9.40957 6.227735 10.14016 4.216989 5.93688]; 
CO_NI = [0.196 0.454 0.678 0.666 0.736]; 
CO_STD_NI = [0.085615 0.191651 0.337224 0.26025 0.24684]; 

% H2 Non-isothermal data
% H2_NI = [28.62 19.338 20 19.836 21.984];
% H2_STD_NI = [9.907169 8.642912 8.406497 6.257326 4.596486];
H2_NI = [0.25 0.68 0.206 0.232 0.296];
H2_STD_NI = [0.130576 0.0690665 0.075033 0.093381 0.130307];

% CO Isothermal data
% CO_I = [14.992 20.372 20.632 17.8 21.972]; 
% CO_STD_I = [5.387551 9.13645 8.555979 8.258583 13.3592]; 
CO_I = [0.108 0.1866 0.19 0.146 0.148]; 
CO_STD_I = [0.027749 0.072061 0.056125 0.04827 0.078867]; 

% H2 Isothermal data
% H2_I = [30.646	29.174	29.394	34.554	38.282];
% H2_STD_I = [6.524188072	8.52568355 5.326854607	8.079036452	6.774195155];
H2_I = [0.33 0.214 0.23 0.318 0.354];
H2_STD_I = [0.127279 0.136858 0.072801 0.12276 0.118448];

%% MAIN 
% Plot
fig = figure(Theme='light', Units='inches');
ax = axes(fig, Units='inches');

% b1 = bar(ax, x, [y1; y2]');
% 
hold on
% 
% b2 = bar(ax, x, [y3; y4]');
% 
% errorbar(b1(1).XEndPoints, y1, stdy1, 'LineStyle', 'none', 'LineWidth', 1.5, 'Color', [0.1 0.1 0.1])
% errorbar(b1(2).XEndPoints, y2, stdy2, 'LineStyle', 'none', 'LineWidth', 1.5, 'Color', [0.1 0.1 0.1])

colorsA = {
    [0.0000 0.4470 0.7410]; % blue
    [0.4 0.4 0.4];          % grey
};

colorsB = {
    [0.9000 0.3250 0.0980]; % orange-red
    [0.7 0.7 0.7];          % light grey
};

yA = [CO_I; H2_I]';
yB = [CO_NI; H2_NI]';

stdA = [CO_STD_I; H2_STD_I]';
stdB = [CO_STD_NI; H2_STD_NI]';

nGroups = length(yA);
barWidth = 0.3;
groupSeparation = 0.05;

for i = 1:nGroups
    x1 = i - barWidth/2 - groupSeparation;
    x2 = i + barWidth/2 + groupSeparation;

    hA = bar(ax, x1, yA(i,:), barWidth, 'stacked');
    hB = bar(ax, x2, yB(i,:), barWidth, 'stacked');

    errorbar(ax, [hA.XEndPoints], [hA.YEndPoints], stdA(i,:), LineStyle = 'none', LineWidth = 1.5, Color = [0.1 0.1 0.1])
    errorbar(ax, [hB.XEndPoints], [hB.YEndPoints], stdB(i,:), LineStyle = 'none', LineWidth = 1.5, Color = [0.1 0.1 0.1])

    for j = 1:numel(hA)
        hA(j).FaceColor = colorsA{j};
        hB(j).FaceColor = colorsB{j};
    end
end

% Configuring bars
b1(1).LineWidth = 1.5;
b1(2).LineWidth = 1.5;
b1(1).BarWidth = 0.8;
b1(2).BarWidth = 0.8;


bars = findall(ax, Type='Bar');
set(bars, ...
    LineWidth = 1.5);


% Configuring axes
PlotWidth = 5;
AspectRatio = 1.2;

ax.YLim = [0 1.5];
ax.XLim = [0 nGroups + 1];
ax.XTickLabels = ['' x '']; % The left and right '' are to remove the first and last tick labels which are not needed
ax.LineWidth = 1.5;
ax.FontName = 'Arial';
ax.FontSize = 16;

xlabel('{\itT} (°C)', Interpreter='tex', FontSize=18, FontName='Arial')
ylabel('{\itn} (μmol)', Interpreter='tex', FontSize=18, FontName='Arial')

box on

PlotHeight = PlotWidth/AspectRatio;
ax.Position([3 4]) = [PlotWidth PlotHeight];
fig.Position([3 4]) = ax.OuterPosition([3 4]);
ax.OuterPosition(1) = ax.OuterPosition(1) + ax.TickLength(1);

legend(ax, ...
    {'CO', 'H_2', 'CO', 'H_2'}, ...
    'Location', 'northwest')

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)