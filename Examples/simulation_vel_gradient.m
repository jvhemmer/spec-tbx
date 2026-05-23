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
expName = 'Vel Gradient Upright updated radius';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Temperature gradient effect on CO2RR\Revision 1\New or Edited Figures\Updated 1 mm simulation\Regular Disk Velocity Gradient T=35 r=0.5 z=8 updated.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Temperature gradient effect on CO2RR\Revision 1\New or Edited Figures\Updated 1 mm simulation\Regular Disk Velocity Gradient T=35 r=1 z=8.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Temperature gradient effect on CO2RR\Revision 1\New or Edited Figures\Updated 1 mm simulation\Regular Disk Velocity Gradient T=35 r=2 z=8.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Temperature gradient effect on CO2RR\Revision 1\New or Edited Figures\Updated 1 mm simulation\Regular Disk Velocity Gradient T=35 r=4 z=8.txt"
};

% General parameters
saveToAnalysisFolder = false;
% savePath will be ignored if saveToAnalysisFolder is true
savePath = "C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Temperature gradient effect on CO2RR\Revision 1\New or Edited Figures\Updated 1 mm simulation";

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

% Velocity gradient for different radii and depths colors
colors ={
  [0.10 0.10 0.10]      % dark grey
  [0.28 0.40 0.11]      % dark green
  [0.47 0.67 0.19]      % green
  [0.63 0.77 0.43]      % light green
  [0.84 0.90 0.76]      % lighter green
};

% Temperature gradient colors
% colors = {
%     [0.10 0.10 0.10]        % dark grey
%     [0.45 0.00 0.00]        % 
%     [0.90 0.00 0.00]        %
%     [0.95 0.50 0.50]
% };

% Different electrode geom
% colors ={
%   [0.10 0.10 0.10]      % dark grey
%   [0.00 0.45 0.74]      % blue
%   [0.47 0.67 0.19]      % green
% };

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
    YLim =          [0 0.5], ...
    XLim =          [0 8], ...
    XTick =         [], ...
    YTick =         [], ...
    LineWidth =     1.5, ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    FigureName =    'velocity_gradient', ...
    Color =         colors ...
    );

% legendLabels = strsplit(num2str(conditions));
legendLabels = {'0.5'; '1'; '2'; '4'};
% legendLabels = createLegendLabels([40 50 75], Suffix=' °C', Decimals=1);

legend(ax, ...
    label = legendLabels, ...
    Location = 'northeast')

% Creating folder to save analysis
if saveToAnalysisFolder == true
    % Creating folder to save analysis
    savePath = createAnalysisFolder(dataPath{1}, expName);
    
    % Copy files
    if isfile(dataPath{1})
        copyFile(savePath, dataPath)
    end
else
    if not(exist('savePath', 'var'))
        savePath = fileparts(dataPath{1});
    end
end

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

