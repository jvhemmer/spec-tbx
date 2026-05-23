e% BarPlot: Plot simple bar plots.
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
expName = 'FE and NumMoles L-shaped constant current (matching axes from CP experiment)';

% Path to save data
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Temperature gradient effect on CO2RR\Revision 1\New or Edited Figures\Constant current"
};

% General parameters
saveToAnalysisFolder = true;

% Data
x = ["0" "10"];

%% r = 1 mm (i.e., d = 2 mm), z = 8 mm
% NumMoles
% CO_AVG = [0.088 0.123];
% CO_STD = [0.038018 0.057263];
% 
% H2_AVG = [0.103 0.155];
% H2_STD = [0.026963 0.043486];

% FE
% CO_AVG = [35.44 39.42];
% CO_STD = [14.87344 20.76959];
% 
% H2_AVG = [39.08 48.75333];
% H2_STD = [9.85714 17.72965];

%% r = 1 mm (i.e., d = 2 mm), z = 8 mm
% NumMoles
% CO_AVG = [0.316667 0.473333];
% CO_STD = [0.051316 0.041633];
% 
% H2_AVG = [0.316667 0.953333];
% H2_STD = [0.020817 0.290230];

% FE
% CO_AVG = [33.48 31.96];
% CO_STD = [4.56 5.47];
% 
% H2_AVG = [33.86667 61.6];
% H2_STD = [1.375148 6.479498];

%% New data
% NumMoles
% CO_AVG = [0.102667 0.101667];
% CO_STD = [0.011015 0.044747];
% 
% H2_AVG = [0.746667 1.376667];
% H2_STD = [0.025166 0.236925];

% FE
% CO_AVG = [9.43 5.98];
% CO_STD = [1.26 2.11];
% 
% H2_AVG = [67.22 83.44];
% H2_STD = [5.85 2.11];

%% New data
% NumMoles
% CO_AVG = [0.102667 0.101667];
% CO_STD = [0.011015 0.044747];
% 
% H2_AVG = [0.746667 1.376667];
% H2_STD = [0.025166 0.236925];

%% New data 2
% % NumMoles
% CO_n_AVG = [0.179667 0.3];
% CO_n_STD = [0.012423 0.026458];
% 
% H2_n_AVG = [0.393333 0.84];
% H2_n_STD = [0.085049 0.08544];
% 
% % FE
% CO_FE_AVG = [22.20667 23.69];
% CO_FE_STD = [3.090378 0.840417];
% 
% H2_FE_AVG = [48.18 65.91333];
% H2_FE_STD = [10.04838 9.842486];

%% L-shaped constant current
% % NumMoles
CO_n_AVG = [0.307 0.903];
CO_n_STD = [0.021 0.222];

H2_n_AVG = [0.310 0.470];
H2_n_STD = [0.026 0.020];

% % FE
CO_FE_AVG = [38.630 50.163];
CO_FE_STD = [2.966 12.629];

H2_FE_AVG = [38.893 26.343];
H2_FE_STD = [3.829 0.915];

% y1 = CO_AVG;
% y2 = H2_AVG;
% stdy1 = CO_STD;
% stdy2 = H2_STD;

%% MAIN 
% Figure 1 (FE)
fig = figure(Theme='light', Units='inches');
ax = axes(fig, Units='inches');

b1 = bar(ax, x, [CO_FE_AVG; H2_FE_AVG]');

hold on

errorbar(ax, b1(1).XEndPoints, CO_FE_AVG, CO_FE_STD, 'LineStyle', 'none', 'LineWidth', 1.5, 'Color', [0.1 0.1 0.1])
errorbar(ax, b1(2).XEndPoints, H2_FE_AVG, H2_FE_STD, 'LineStyle', 'none', 'LineWidth', 1.5, 'Color', [0.1 0.1 0.1])

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

ax.YLim = [0 100];
ax.LineWidth = 1.5;
ax.FontName = 'Arial';
ax.FontSize = 16;

% xlabel('{\itT} (°C)', Interpreter='tex', FontSize=18, FontName='Arial')
xlabel('Δ{\itT} (°C)', Interpreter='tex', FontSize=18, FontName='Arial')
ylabel('FE (%)', Interpreter='tex', FontSize=18, FontName='Arial')


PlotHeight = PlotWidth/AspectRatio;
ax.Position([3 4]) = [PlotWidth PlotHeight];
fig.Position([3 4]) = ax.OuterPosition([3 4]);
ax.OuterPosition(1) = ax.OuterPosition(1) + ax.TickLength(1);

legend(ax, ...
    {'CO', 'H_2'}, ...
    'Location', 'northwest')

%% Figure 2 (n)
fig2 = figure(Theme='light', Units='inches');
ax2 = axes(fig2, Units='inches');

b2 = bar(ax2, x, [CO_n_AVG; H2_n_AVG]');

hold on

errorbar(ax2, b2(1).XEndPoints, CO_n_AVG, CO_n_STD, 'LineStyle', 'none', 'LineWidth', 1.5, 'Color', [0.1 0.1 0.1])
errorbar(ax2, b2(2).XEndPoints, H2_n_AVG, H2_n_STD, 'LineStyle', 'none', 'LineWidth', 1.5, 'Color', [0.1 0.1 0.1])

% Configuring bars
b2(1).FaceColor = colorsB{1};
b2(2).FaceColor = colorsB{2};
% b1(1).BarLayout = 'stacked';
% b1(2).BarLayout = 'stacked';
b2(1).LineWidth = 1.5;
b2(2).LineWidth = 1.5;
b2(1).BarWidth = 0.8;
b2(2).BarWidth = 0.8;

% Configuring axes
PlotWidth = 5;
AspectRatio = 1.2;

ax2.YLim = [0 2];
ax2.LineWidth = 1.5;
ax2.FontName = 'Arial';
ax2.FontSize = 16;

% xlabel(ax2, '{\itT} (°C)', Interpreter='tex', FontSize=18, FontName='Arial')
xlabel(ax2, 'Δ{\itT} (°C)', Interpreter='tex', FontSize=18, FontName='Arial')
ylabel(ax2, '{\itn} (μmol)', Interpreter='tex', FontSize=18, FontName='Arial')

PlotHeight = PlotWidth/AspectRatio;
ax2.Position([3 4]) = [PlotWidth PlotHeight];
fig2.Position([3 4]) = ax2.OuterPosition([3 4]);
ax2.OuterPosition(1) = ax2.OuterPosition(1) + ax2.TickLength(1);

legend(ax2, ...
    {'CO', 'H_2'}, ...
    'Location', 'northwest')

%% Combine both figures
% tiledfig = figure('Theme', 'light', 'Name', 'FE and n', 'WindowStyle', 'normal');
% t = tiledlayout(tiledfig, 1, 2);
% cax = copyobj(ax, t);
% cax.Layout.Tile = 1;
% cax2 = copyobj(ax2, t);
% cax2.Layout.Tile = 2;
% newAx1 = copyobj(ax, tiledfig);
% newAx2 = copyobj(ax2, tiledfig);
% set(newAx1, 'Position', ax.Position); % left panel
% 
% ax2P = ax2.Position;
% ax2P(1) = ax2.Position(1) + ax.Position(3);
% set(newAx2, 'Position', ax2P); % right panel

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
