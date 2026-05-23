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
expName = 'NumMoles Different potentials isothermal 25C';

% Path to save data
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Temperature gradient effect on CO2RR\Revision 1\New or Edited Figures\FE and NumMoles"
};

% General parameters
saveToAnalysisFolder = true;

% Data
x = ["−1.60" "−1.65" "−1.70"];

%% Non-isothermal Ts = 35C, Tb = 25C
% NumMoles
% CO_AVG = [0.139667	0.200333333	0.73];
% CO_STD = [0.009018	0.060797478	0.24];
% 
% H2_AVG = [0.0897	0.1043	0.2900];
% H2_STD = [0.0087	0.0302	0.1300];

% FE
% CO_AVG = [46.57 53.64 55.14];
% CO_STD = [4.48 13.20 5.94];
% 
% H2_AVG = [29.88 28.47 21.98];
% H2_STD = [3.37 5.44 4.60];

%% Isothermal T = 35C
% NumMoles
% CO_AVG = [0.06	0.1	0.14];
% CO_STD = [0.01	0.01	0.07];
% 
% H2_AVG = [0.135667	0.132	0.35];
% H2_STD = [0.031134	0.048135226	0.11];

% FE
% CO_AVG = [20.13	31.28333333	21.972];
% CO_STD = [3.22018633	5.966174095	13.35919608];
% 
% H2_AVG = [40.82	37.73333333	38.282];
% H2_STD = [9.086275365	5.223995916	6.774195155];

%% Isothermal T = 25C
% NumMoles
CO_AVG = [0.083	0.126666667	0.19];
CO_STD = [0.034771	0.015275252	0.08];

H2_AVG = [0.102333	0.09	0.25];
H2_STD = [0.029501	0.01	0.13];

% FE
% CO_AVG = [28.87	36.86666667	28];
% CO_STD = [13.05013027	6.569393681	9.409569597];
% 
% H2_AVG = [35.32666667	26.88333333	28.62];
% H2_STD = [8.900428829	5.939767111	9.907169121];

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

% ax.YLim = [0 80];
ax.YLim = [0 1.2];
ax.LineWidth = 1.5;
ax.FontName = 'Arial';
ax.FontSize = 16;

xlabel('{\itE} (V vs. Ag/AgCl)', Interpreter='tex', FontSize=18, FontName='Arial')
% ylabel('FE (%)', Interpreter='tex', FontSize=18, FontName='Arial')
ylabel('{\itn} (μmol)', Interpreter='tex', FontSize=18, FontName='Arial')

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
