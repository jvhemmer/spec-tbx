% Plot temperature vs time from data files obtained from OCR.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   4 Dec 2025
clear
close
clc

%% BASIC PARAMETERS
% Experiment name (comment out or leave blank to use file name)
expName = "T chop 473 5min avg15 thin";

% Path to data files (one per line)
dataPath = { 
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\EM-field mass transfer\R1 Data\Image Recognition\blue_5min_avg15.csv"
};

% General parameters
saveToAnalysisFolder = true;

% Plotting options
YScaleFactor = 1; 

% Green 1min
% minimum_T = 22.6;
% maximum_T = 24.5;

% Blue 1min
% minimum_T = 21.9;
% maximum_T = 24;

% Green 5min
% minimum_T = 21.6;
% maximum_T = 24.7;

% Blue 5min
minimum_T = 21.3;
maximum_T = 24.6;

% Colors 
colors = {
    % [0.1 0.1 0.1]
    [0, 0.4470, 0.7410]         % blue
    % [0 0.5 0]                   % dark green
    % [1 0 0]
};

%% MAIN 
% Read data
[time, temp] = readDataPath(dataPath, 1, 2);

% Corrections and adjustments
nFiles = length(dataPath); % number of files
for f = 1:nFiles
end

T = temp{1};
t = time{1};

% Remove values outside range (including NaNs)
valid = (T >= minimum_T) & (T <= maximum_T);
valid = valid & ~isnan(T);

T = T(valid);
t = t(valid);

i = 2;
while i < length(T)
    if abs(T(i) - T(i-1)) > 0.11
        disp(append(num2str(T(i))," came after ", num2str(T(i-1)), " at ", num2str(t(i), 3)))
        T(i-1) = [];
        t(i-1) = [];
    else
        i = i + 1; 
    end
end


[fig, ax] = plotXY(t, T, ... 
    XLabel =        '{\itt} (s)', ...
    YLabel =        '{\itT} (°C)', ...
    YLim =          [21 26], ...
    XLim =          [0 3000], ...
    XTick =         [], ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    LineWidth =     2, ...
    FigureName =    'T', ...
    MinusSignOnAx = true, ...
    Color =         colors, ...
    YScaleFactor =  YScaleFactor);

% ax.YTick = [];

% l = legend(ax, {"473 nm"; "532 nm"}, ...
%     'Location', 'southeast', ...
%     'FontSize', 18);

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
