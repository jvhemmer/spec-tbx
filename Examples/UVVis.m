% UVVis: Plot UV-Vis from data files.
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
expName = 'E2 (rough step2 only, unbuff coupling) CV 50mVps, 3rd cycle, filter 10 and 20Hz';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\02282025\E2 (rough step2 only, unbuffered coupling) CV 50mVps.txt"
};

% Experiment parameters
% YScaleFactor = 1e6;

% Reading data
[wavelength, absorbance] = readDataPath(dataPath, 1, 2);

[fig, ax] = plotXY(wavelength, absorbance, ...
    'XLabel', '{\itλ} (nm)', ...
    'YLabel', '{\itA}', ...
    'XLim', [], ...
    'YLim', [], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'FigureName', 'uvvis');

legend(ax, ...
    {'0 µL PtCl2'; '50 µL PtCl2'; '150 µL PtCl2'; '200 µL PtCl2'; '250 µL PtCl2'}, ...
    'Location', 'northeast')

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)