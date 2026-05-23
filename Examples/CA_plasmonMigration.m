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
expName = "CA chopped 5min 532 vs 473";

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\EM-field mass transfer\R1 Data\532 nm\532 nm\T3 532 nm CA 5 min.txt" 
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\EM-field mass transfer\R1 Data\532 nm\532 nm\T2 532 nm CA 5 min.txt"
};

% Path to background files (one per line)
bkgPath = {
};

% General parameters
saveToAnalysisFolder = true;

% Plotting options
YScaleFactor = 1e3; 
% offset = [-0.8e-6 -0.5e-6 -1.2e-6];

% Colors for 532 nm
% colors = {
%     [0.1 0.1 0.1]               % dark grey
%     [0.9 0 0]                   % strong red
%     % [0.4660 0.6740 0.1880]      % green
%     [0 0.5 0]                   % dark green
% };

% Colors for 473 nm
% colors = {
%     [0.1 0.1 0.1]               % dark grey
%     [0.9 0 0]                   % strong red
%     [0, 0.4470, 0.7410]         % blue
%     % [0 0 0.8]                   % dark blue
% };

% Experimental params
% pH = 13.7;
% ERHE = @(E) 0.222 + 13.7*0.059 + E;
electrodeDiameter = 0.2; % in cm

%% MAIN 
% Read data
[time, current] = readDataPath(dataPath, 1, 2);

nFiles = length(dataPath); % number of files

% Data processing (comment out what is not necessary)

% Process background 
if not(isempty(bkgPath))
    nBkg = length(bkgPath);
    bkgCurrent = cell([nFiles 1]);
    for i = 1:nBkg
        [~, bkgCurrent{i}] = readData(bkgPath{i}, 1, 2);

        current{i} = current{i} - bkgCurrent{i}; % Subtract background current
    end
end

% Corrections and adjustments
for i = 1:nFiles
    % potential{i} = potential{i}/1000;

    % current{i} = current{i} - offset(i); % offset data

    % potential{i} = ERHE(potential{i}); % convert potential from Ag/AgCl to RHE

    current{i} = current{i} / (pi * electrodeDiameter^2 / 4);
end

[fig, ax] = plotXY(time, current, ... 
    XLabel =        '{\itt} (s)', ...
    YLabel =        '{\itj} (mA cm^{−2})', ...
    YLim =          [-1 0], ...
    XLim =          [0 3000], ...
    XTick =         [], ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    LineWidth =     2, ...
    FigureName =    'CA', ...
    MinusSignOnAx = true, ...
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
