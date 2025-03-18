% simulation_T_gradient: Plot simulated temperature gradient data obtained
% from COMSOL.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   2 Feb 2025
clear
close all
clc

%% BASIC PARAMETERS
% Experiment name (comment out or leave blank to use file name)
expName = 'temperature gradient';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\temperature gradient T=27c.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\temperature gradient T=30c.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\temperature gradient T=32c.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\temperature gradient T=35c.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\temperature gradient T=25c.txt"
};

% Plotting options
YScaleFactor = 1;
colors = {
    [0.0 0 0];
    [0.3 0 0];
    [0.6 0 0];
    [0.9 0 0];
    [1.0 0 0]
    };

%% MAIN 
nFiles = length(dataPath); % number of files

z = cell([nFiles 1]); % preallocate arrays
T = cell([nFiles 1]);

for i = 1:nFiles % read all data files
    [z{i}, T{i}] = readData(dataPath{i}, 1, 2);
end

% Plot first file
[fig, ax] = plotXY(z, T, ... 
    XLabel =        '{\itz} (mm)', ...
    YLabel =        '{\itT} (°C)', ...
    YLim =          [24 36], ...
    XLim =          [0 4], ...
    XTick =         [0:0.5:4], ...
    YTick =         [25:2:35], ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    FigureName =    'temperature_gradient', ...
    YScaleFactor =  YScaleFactor, ...
    Color =         colors ...
    );

legend(ax, ...
    label = {'25 °C'; '27 °C'; '30 °C'; '32 °C'; '35 °C'}, ...
    Location = 'best')

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)
