% CA: Plot chronoamperograms from data files.
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
expName = "CA chopped 1min 532 vs 473 AVG";

% Path to data files (one per line)
dataPath = { 
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\EM-field mass transfer\R1 Data\473 nm\473 nm\T1 473 nm CA 1 min.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\EM-field mass transfer\R1 Data\473 nm\473 nm\T2 473 nm CA 1 min.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\EM-field mass transfer\R1 Data\473 nm\473 nm\T3 473 nm CA 1 min.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\EM-field mass transfer\R1 Data\532 nm\532 nm\T1 532 nm CA 1 min.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\EM-field mass transfer\R1 Data\532 nm\532 nm\T2 532 nm CA 1 min.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\EM-field mass transfer\R1 Data\532 nm\532 nm\T3 532 nm CA 1 min.txt" 
};

% General parameters
saveToAnalysisFolder = true;

% Plotting options
YScaleFactor = 1e3; 

% Colors 
colors = {
    [0, 0.4470, 0.7410]         % blue
    [0 0.5 0]                   % dark green
};

% Experimental params
electrodeDiameter = 0.2; % in cm

%% MAIN 
% Read data
[time, current] = readDataPath(dataPath, 1, 2);

% Corrections and adjustments
nFiles = length(dataPath); % number of files
for i = 1:nFiles
    current{i} = current{i} / (pi * electrodeDiameter^2 / 4);
end

% Average first three currents
average473 = mean(cell2mat(current(1:3)), 2);
average532 = mean(cell2mat(current(4:6)), 2);

current = {average473; average532};

[fig, ax] = plotXY(time{1}, current, ... 
    XLabel =        '{\itt} (s)', ...
    YLabel =        '{\itj} (mA cm^{−2})', ...
    YLim =          [-1 0], ...
    XLim =          [0 600], ...
    XTick =         [], ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    LineWidth =     2, ...
    FigureName =    'CA', ...
    MinusSignOnAx = true, ...
    Color =         colors, ...
    YScaleFactor =  YScaleFactor);

% ax.YTick = [];

l = legend(ax, {"473 nm"; "532 nm"}, ...
    'Location', 'southeast', ...
    'FontSize', 18);

% Annotation in the plot
% Tm = mean(T);
% Ts = std(T);
% 
% formatSpec = '%.1f';
% str = append("{\itT} = ", num2str(Tm,formatSpec), " ± ", num2str(Ts,formatSpec), " °C");
% an = annotation(fig, 'textbox', String=str, FitBoxToText='on', LineWidth=1.5, FontName='Arial', FontSize=16);
% an.Units = 'inches';
% an.Position = [ax.Position(1) + 0.15, ax.Position(3) - an.Position(3) - 0.2, an.Position(3), an.Position(4)];

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
