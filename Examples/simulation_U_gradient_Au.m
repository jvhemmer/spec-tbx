% Plot simulated velocity gradient data obtained from COMSOL.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   21 Nov 2025
clear
close all
clc

%% BASIC PARAMETERS
% Experiment name (comment out or leave blank to use file name)
expName = 'Velocity gradients';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\Box\Johann Hemmer Data\EM-field mass transfer\COMSOL\11 Nov\11212025\Velocity - Heating from Laser T_e=25.5C.txt" 
"C:\Users\jhemmer\Box\Johann Hemmer Data\EM-field mass transfer\COMSOL\11 Nov\11212025\Velocity - Heating from Block T_set=25.5C.txt" 
"C:\Users\jhemmer\Box\Johann Hemmer Data\EM-field mass transfer\COMSOL\11 Nov\11212025\Velocity - Heating from Laser T_e=29.4C.txt" 
"C:\Users\jhemmer\Box\Johann Hemmer Data\EM-field mass transfer\COMSOL\11 Nov\11212025\Velocity - Heating from Block T_set=29.4C.txt"
};

% General parameters
saveToAnalysisFolder = true;
% z_e = 10; % Depth of the electrode surface, in mm

% Plotting options
YScaleFactor = 1;
colors = {
  [0 0.5 0] % green
  [0 0.5 0]
  [0 0.4470 0.7410] % blue
  [0 0.4470 0.7410]
};

%% MAIN 
nFiles = length(dataPath); % number of files

z = cell([nFiles 1]); % preallocate arrays
u = cell([nFiles 1]);

for i = 1:nFiles % read all data files
    [z{i}, u{i}] = readData(dataPath{i}, 1, 2);
end

% Plot first file
[fig, ax] = plotXY(z, u, ... 
    XLabel =        '{\itz} (mm)', ...
    YLabel =        '{\itu} (mm s^{−1})', ...
    YLim =          [], ...
    XLim =          [0 5], ...
    XTick =         [], ...
    YTick =         [], ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    LineWidth =     2, ...
    FigureName =    'velocity_gradient', ...
    YScaleFactor =  YScaleFactor, ...
    Color =         colors, ...
    LineStyle =     {'-', '--', '-', '--'} ...
    );

legend(ax, ...
    label = {'532 nm'; '25.5 °C'; '473 nm'; '29.4 °C'}, ...
    Location = 'best')

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

% Copy files
copyFile(savePath, dataPath)
