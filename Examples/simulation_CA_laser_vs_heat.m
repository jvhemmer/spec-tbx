% Plot simulated CAs from COMSOL.
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
expName = 'CA heating from block vs laser INSET';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\Box\Johann Hemmer Data\EM-field mass transfer\COMSOL\11 Nov\11212025\Current Densities Heating from Laser T=25.5C.txt"
"C:\Users\jhemmer\Box\Johann Hemmer Data\EM-field mass transfer\COMSOL\11 Nov\11212025\Current Densities Heating from Block T=25.5C.txt"
"C:\Users\jhemmer\Box\Johann Hemmer Data\EM-field mass transfer\COMSOL\11 Nov\11212025\Current Densities Heating from Laser T=29.4C.txt"
"C:\Users\jhemmer\Box\Johann Hemmer Data\EM-field mass transfer\COMSOL\11 Nov\11212025\Current Densities Heating from Block T=29.4C.txt"
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
T = cell([nFiles 1]);

for i = 1:nFiles % read all data files
    [z{i}, T{i}] = readData(dataPath{i}, 1, 2);
end

% Plot first file
[fig, ax] = plotXY(z, T, ... 
    XLabel =        '{\itt} (s)', ...
    YLabel =        '{\itj} (mA cm^{−2})', ...
    YLim =          [-0.225 -0.125], ...
    XLim =          [400 500], ...
    XTick =         [], ...
    YTick =         [], ...
    AspectRatio =   1.2, ...
    PlotWidth =     2, ...
    LineWidth =     2, ...
    FigureName =    'CA', ...
    YScaleFactor =  YScaleFactor, ...
    Color =         colors, ...
    LineStyle =     {'-', '--', '-', '--'} ...
    );

% legend(ax, ...
%     label = {'532 nm'; '25.5 °C'; '473 nm'; '29.4 °C'}, ...
%     Location = 'best')

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
