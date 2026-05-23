% BarPlot: Plot simple bar plots.
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
expName = 'FE different stirring speeds isothermal';

% Path to save data
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Temperature gradient effect on CO2RR\Revision 1\New or Edited Figures\Stirring"
};

% General parameters
saveToAnalysisFolder = true;

% Data
x = ["0" "100" "500"];

%% 0, 100 and 500 rpm, T = 
% NumMoles
% CO_AVG = [0.122667 0.176 0.2];
% CO_STD = [0.028184 0.010392 0.022068];
% 
% H2_AVG = [0.151333 0.085667 0.1111];
% H2_STD = [0.01193 0.030039 0.034896];

% FE
CO_AVG = [40.69333 44.68667 44.08333];
CO_STD = [7.791112 6.557876 7.536925];

H2_AVG = [48.12667 21.58 24.16667];
H2_STD = [2.747805 6.4626 7.769384];

y1 = CO_AVG;
y2 = H2_AVG;
stdy1 = CO_STD;
stdy2 = H2_STD;

%% MAIN 
% Plot
fig = figure(Theme='light', Units='inches');
ax = axes(fig, Units='inches');

b1 = bar(ax, x, [y1; y2]');

hold on

errorbar(b1(1).XEndPoints, y1, stdy1, 'LineStyle', 'none', 'LineWidth', 1.5, 'Color', [0.1 0.1 0.1])
errorbar(b1(2).XEndPoints, y2, stdy2, 'LineStyle', 'none', 'LineWidth', 1.5, 'Color', [0.1 0.1 0.1])

colorsA = {
    [0.0000 0.4470 0.7410]; % blue
    [0.4 0.4 0.4];          % grey
};

colorsB = {
    [0.9000 0.3250 0.0980]; % orange-red
    [0.7 0.7 0.7];          % light grey
};

% Configuring bars
b1(1).FaceColor = colorsA{1};
b1(2).FaceColor = colorsA{2};
% b1(1).BarLayout = 'stacked';
% b1(2).BarLayout = 'stacked';
b1(1).LineWidth = 1.5;
b1(2).LineWidth = 1.5;
b1(1).BarWidth = 0.8;
b1(2).BarWidth = 0.8;

% Configuring axes
PlotWidth = 5;
AspectRatio = 1.2;

ax.YLim = [0 80];
% ax.YLim = [0 1.2];
ax.LineWidth = 1.5;
ax.FontName = 'Arial';
ax.FontSize = 16;

xlabel('{\it\omega} (min^{−1})', Interpreter='tex', FontSize=18, FontName='Arial')
ylabel('FE (%)', Interpreter='tex', FontSize=18, FontName='Arial')
% ylabel('{\itn} (μmol)', Interpreter='tex', FontSize=18, FontName='Arial')

PlotHeight = PlotWidth/AspectRatio;
ax.Position([3 4]) = [PlotWidth PlotHeight];
fig.Position([3 4]) = ax.OuterPosition([3 4]);
ax.OuterPosition(1) = ax.OuterPosition(1) + ax.TickLength(1);

legend(ax, ...
    {'CO', 'H_2'}, ...
    'Location', 'northwest')

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
