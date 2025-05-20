% LSV: Plot Linear Sweep Voltammograms from data files.
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
expName = "CA CO2-purged 5mVps Non-isothermal Trial 1";

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Data from Amin\CA Heating surface\ES CA Surafce Trial 3\ES25 15 min.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Data from Amin\CA Heating surface\ES CA Surafce Trial 3\ES27 15 min.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Data from Amin\CA Heating surface\ES CA Surafce Trial 3\ES30 15 min.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Data from Amin\CA Heating surface\ES CA Surafce Trial 3\ES32 15 min.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Data from Amin\CA Heating surface\ES CA Surafce Trial 3\ES35 15 min.txt"
};

% Path to background files (one per line)
bkgPath = {
};

% Plotting options
YScaleFactor = 1e3; 
% offset = [-0.8e-6 -0.5e-6 -1.2e-6];

% Color for the non-isothermal (gradient)
colors = {
    [0.1000 0.1000 0.1000]      % dark grey
    [0.4660 0.6740 0.1880]      % green
    [0.8290 0.6940 0.1250]      % burnt yellow
    [0.8000 0.3250 0.0980]      % orange-brown
    [0.9000 0.0000 0.0000]      % strong red
};

% Color for isothermal condition
% colors = {
%     [0.1000 0.1000 0.1000]      % dark grey
%     [0.0000 0.2235 0.5500]      % dark blue
%     [0.0000 0.4470 0.7410]      % blue
%     [0.3000 0.6500 0.9200]      % light blue
%     [0.5000 0.8500 0.9900]      % lighter blue
% };

% Experimental params
% T = [30.0 30.2 30.3];
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
    YLim =          [-30 -5], ...
    XLim =          [0 600], ...
    XTick =         [], ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    LineWidth =     1.5, ...
    Color =         colors, ...
    FigureName =    'CA', ...
    MinusSignOnAx = true, ...
    YScaleFactor =  YScaleFactor);

% ax.YTick = [];

legend(ax, ...
    {'25.0'; '27.0'; '30.0'; '32.0'; '35.0'}, ...
    'Location', 'southeast')

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
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveFig(fig, 'output', savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)
