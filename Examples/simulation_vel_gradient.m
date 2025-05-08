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
expName = 'velocity gradient (L-shape) r=1 all depths ZOOM';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\New simulations\L-shaped\temperature gradient L-shape T=35 z=4 r=1.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\New simulations\L-shaped\temperature gradient L-shape T=35 z=8 r=1.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\New simulations\L-shaped\temperature gradient L-shape T=35 z=12 r=1.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\New simulations\L-shaped\temperature gradient L-shape T=35 z=18 r=1.txt"
};

% Plotting options
YScaleFactor = 1;

% Non-isothermal colors
% colors = {
%     [0.1000 0.1000 0.1000]      % dark grey
%     [0.4660 0.6740 0.1880]      % green
%     [1.0000 0.8200 0.0600]      % burnt yellow
%     [0.9500 0.5200 0.3000]      % orange-brown
%     [0.9000 0.0000 0.0000]      % strong red
% };

% Velocity gradient colors
% colors ={
%   [0.10 0.10 0.10]      % dark grey
%   [0.28 0.40 0.11]      % dark green
%   [0.47 0.67 0.19]      % green
%   [0.63 0.77 0.43]      % light green
%   [0.84 0.90 0.76]      % lighter green
% };

% Temperature gradient colors
colors = {
    [0.10 0.10 0.10]        % dark grey
    [0.45 0.00 0.00]        % 
    [0.90 0.00 0.00]        %
    [0.95 0.50 0.50]
};

% Condition data
T = [4 8 12 18];

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
    XLabel =        '{\ity} (mm)', ...
    YLabel =        '{\itu} (mm/s)', ...
    YLim =          [0 1.7], ...
    XLim =          [0 8], ...
    XTick =         [], ...
    YTick =         [], ...
    LineWidth =     1.5, ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    FigureName =    'velocity_gradient', ...
    Color =         colors ...
    );

legend(ax, ...
    label = {'4'; '8'; '12'; '18'}, ...
    Location = 'best')

% % Plot vel vs T
% [fig2, ax2] = plotXY(T, maxU, ... 
%     XLabel =        '{\itT} (°C)', ...
%     YLabel =        '{\itu}_{max} (mm/s)', ...
%     YLim =          [-0.1 1.7], ...
%     XLim =          [24 36], ...
%     XTick =         [25:2:35], ...
%     YTick =         [], ...
%     LineWidth =     1.5, ...
%     AspectRatio =   1.2, ...
%     PlotWidth =     5, ...
%     FigureName =    'max velocity vs. temperature', ...
%     LineStyle =     'none', ...
%     Marker =        'o', ...
%     MarkerEdgeColor=[0.0000 0.4470 0.7410], ...
%     MarkerFaceColor=[0.0000 0.4470 0.7410] ...
%     );


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
