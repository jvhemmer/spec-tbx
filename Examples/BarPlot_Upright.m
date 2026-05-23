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
expName = 'FE Upright d=1mm, z=8mm';

% Path to save data
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Temperature gradient effect on CO2RR\Revision 1\New or Edited Figures\Depth and radius\Upright 1 mm"
};

% General parameters
saveToAnalysisFolder = true;

% Data
x = ["0" "10"];

%% 0, 100 and 500 rpm, T = 17.5C
% NumMoles
% CO_AVG = [0.095 0.2167];
% CO_STD = [0.0218 0.0929];
% 
% H2_AVG = [0.77 1.5333];
% H2_STD = [0.1044 0.2686];

% FE
% CO_AVG = [7.13 9.9267];
% CO_STD = [0.95 4.5609];
% 
% H2_AVG = [57.57 68.407];
% H2_STD = [10.298 8.5909];

%% d = 1 mm, z = 8 mm
% NumMoles
% CO_AVG = [0.088 0.123];
% CO_STD = [0.038018 0.057263];
% 
% H2_AVG = [0.103 0.155];
% H2_STD = [0.026963 0.043486];

% FE
CO_AVG = [35.44 39.42];
CO_STD = [14.87344 20.76959];

H2_AVG = [39.08 48.75333];
H2_STD = [9.85714 17.72965];

%% d = 2 mm, z = 2 mm
% NumMoles
% CO_AVG = [0.161 0.169];
% CO_STD = [0.046 0.079];
% 
% H2_AVG = [0.083 0.041];
% H2_STD = [0.047 0.023];

% FE
% CO_AVG = [40.23 45.51];
% CO_STD = [9.78 12.57];
% 
% H2_AVG = [24.4 12.89];
% H2_STD = [5.98 6.52];
% 
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
b1(1).FaceColor = colorsB{1};
b1(2).FaceColor = colorsB{2};
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
% ax.YLim = [0 0.6];
ax.LineWidth = 1.5;
ax.FontName = 'Arial';
ax.FontSize = 16;

% xlabel('{\itT} (°C)', Interpreter='tex', FontSize=18, FontName='Arial')
xlabel('Δ{\itT} (°C)', Interpreter='tex', FontSize=18, FontName='Arial')
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
