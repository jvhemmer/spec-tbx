% Plot a histogram.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   23 Oct 2025
clear
close
clc

%% BASIC PARAMETERS
% Experiment name (comment out or leave blank to use file name)
expName = "Diameter";

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\Box\Johann Hemmer Data\Plasmon-induced migration (Amin 3rd project)\SEM\Diameters for Histogram\Diameter.xlsx"
};

% General parameters
saveToAnalysisFolder = false;

%% MAIN 
% Read data
[diameter] = readDataPath(dataPath, 7);
diameter = diameter{1};

average = mean(diameter);
stdev = std(diameter);

nFiles = length(dataPath); % number of files

% Corrections and adjustments
for i = 1:nFiles
    %
end

%% Plotting
fig = figure(Theme='light');
ax = axes(fig);

h = histogram(ax, diameter, 10);
h.LineWidth = 2;

avgline = xline(average, LineWidth=2, Alpha=1, Color=[0.5 0 0]);

hold on
stdbar = fill(ax, [average-stdev average-stdev average+stdev average+stdev], [0 max(ax.YLim) max(ax.YLim) 0], [0.5 0.1 0.1]);
stdbar.FaceAlpha = 0.25;
stdbar.EdgeColor = 'none';

adjustAspectRatio(fig, 5, 1.2)

xlabel('{\itd} (nm)', FontSize=20, FontName='Helvetica')
ylabel('{\itN}', FontSize=20, FontName='Helvetica')

set(ax, FontName='Arial', FontSize=18, LineWidth=2)


%% Saving
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
