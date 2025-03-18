% UVVis_Multicolumns: Plot UV-Vis from a single file containing data from
% multiple different samples in each column.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   20 Aug 2024
clear
close
clc

%% Basic Parameters
% Experiment name (comment out or leave blank to use file name)
expName = 'Colin UV-Vis Ag-Pt nanoparticles different additions of Pt';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\9. Etc\Colin\03062025\CA - Copy\362025\UV-VIS\N3\trial0.csv"
};

% Experiment parameters
ColumnNames = {'0 µL PtCl_2'; '50 µL PtCl_2'; '150 µL PtCl_2'; '200 µL PtCl_2'; '250 µL PtCl_2'};
% nColumns = 5;
nColumns = length(ColumnNames);
% YScaleFactor = 1e6;

% Reading data
fulldata = readmatrix(dataPath{1});

wavelength = { fulldata(:,1) };

absorbance = cell([1 nColumns]);
for i = 1:nColumns
    absorbance{i} = fulldata(:,i+1);
end

[fig, ax] = plotXY(wavelength, absorbance, ...
    'XLabel', '{\itλ} (nm)', ...
    'YLabel', '{\itA}', ...
    'XLim', [], ...
    'YLim', [0 1], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'FigureName', 'uvvis');

legend(ax, ...
    ColumnNames, ...
    'Location', 'northeast')

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)