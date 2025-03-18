% simulation_vel_gradient: Plot simulated velocity gradient data obtained
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
expName = 'velocity gradient';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\velocity gradient T=25c.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\velocity gradient T=27c.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\velocity gradient T=30c.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\velocity gradient T=32c.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\velocity gradient T=35c.txt"
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
u = cell([nFiles 1]);
maxU = zeros([nFiles 1]);
maxZ = zeros([nFiles 1]);

for i = 1:nFiles % read all data files
    [z{i}, u{i}] = readData(dataPath{i}, 1, 2);

    [maxU(i), idx] = max(u{i});
    maxZ(i) = z{i}(idx);
end

% Plot first file
[fig, ax] = plotXY(z, u, ... 
    XLabel =        '{\itz} (mm)', ...
    YLabel =        '{\itu} (mm/s)', ...
    YLim =          [-0.01 0.5], ...
    XLim =          [0 8], ...
    XTick =         [], ...
    YTick =         [], ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    FigureName =    'velocity_gradient', ...
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

% Saving variables
varsToExport = {"maxU"; "maxZ"};
for i = 1:length(varsToExport)
    save( ...
        strcat(savePath, filesep, varsToExport{i}, ".txt"), ...
        varsToExport{i}, ...
        "-ascii" ...
        )
end

% Copy files
copyFile(savePath, dataPath)
