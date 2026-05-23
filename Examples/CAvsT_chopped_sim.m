% Plot chronoamperograms from data files.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   28 Aug 2024
clear
close
clc

%% BASIC PARAMETERS
% Experiment name (comment out or leave blank to use file name)
expName = "CAvsT Step vs chopping 5min";

% Path to data files (one per line)
dataPath = { 
"C:\Users\jhemmer\Box\Johann Hemmer Data\EM-field mass transfer\COMSOL\12 Dec\12032025\CA step illumination 2.5min.txt" 
"C:\Users\jhemmer\Box\Johann Hemmer Data\EM-field mass transfer\COMSOL\12 Dec\12032025\CA 5min chopped illumination.txt"
"C:\Users\jhemmer\Box\Johann Hemmer Data\EM-field mass transfer\COMSOL\12 Dec\12032025\T step illumination 2.5min.txt"
"C:\Users\jhemmer\Box\Johann Hemmer Data\EM-field mass transfer\COMSOL\12 Dec\12032025\T 5min chopped illumination.txt"
};

% General parameters
saveToAnalysisFolder = true;

% Plotting options
YScaleFactor = 1; 

% Colors 
colors = {
    [0.1 0.1 0.1]
    [0, 0.4470, 0.7410]         % blue
    % [0 0.5 0]                   % dark green
};

% Experimental params
electrodeDiameter = 0.2; % in cm

%% MAIN 
% Read data
[time, current] = readDataPath(dataPath, 1, 2);

temperature = current(3:4);
current = current(1:2);

% Corrections and adjustments
nFiles = length(dataPath); % number of files
for i = 1:nFiles
    % current{i} = current{i} / (pi * electrodeDiameter^2 / 4);
end

[fig, ax] = plotXY(time(1:2), current, ... 
    XLabel =        '{\itt} (s)', ...
    YLabel =        '{\itj} (mA cm^{−2})', ...
    YLim =          [-1 0], ...
    XLim =          [0 3000], ...
    XTick =         [], ...
    AspectRatio =   1.2, ...
    LineStyle =     {"--"; "-"}, ...
    PlotWidth =     5, ...
    LineWidth =     2, ...
    FigureName =    'CA', ...
    MinusSignOnAx = true, ...
    Color =         colors, ...
    YScaleFactor =  YScaleFactor);

% ax.YTick = [];

l = legend(ax, {"Step"; "Chopped"}, ...
    'Location', 'southeast', ...
    'FontSize', 18);

hold on
yyaxis left

plot(ax, time{3}, temperature{1})
plot(ax, time{4}, temperature{2})

ylim([22 28])

% Annotation in the plot
% Tm = mean(T);
% Ts = std(T);
% 
% formatSpec = '%.1f';
% str = append("{\itT} = ", num2str(Tm,formatSpec), " ± ", num2str(Ts,formatSpec), " °C");
% an = annotation(fig, 'textbox', String=str, FitBoxToText='on', LineWidth=1.5, FontName='Arial', FontSize=16);
% an.Units = 'inches';
% an.Position = [ax.Position(1) + 0.15, ax.Position(3) - an.Position(3) - 0.2, an.Position(3), an.Position(4)];

% Move last line above the previous one
uistack(ax.Children(end), "up")

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
saveFig(fig, 'output', savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)
