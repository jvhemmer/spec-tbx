% FWHM: Calculate the width at 50% of a peak's height (full width half max)
% and plot the result.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   14 Apr 2025
clear
close
clc

%% Basic Parameters
% Experiment name (comment out or leave blank to use file name)
expName = '';

% Path to data file (one file only)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\08. Internal\Colin\UV-Vis for most recent batch\04082025\Uv-Vis\N0.csv"
};

% Parameters
baselineRange = [325 500]; % peak start and peak end

% Reading data
[x, y] = readDataPath(dataPath, 1, 2);

% Doing analysis one data file at a time
x = x{1};
y = y{1};

% x and y values at the specified baseline range
xRange = x(x >= baselineRange(1) & x <= baselineRange(2));
yRange = y(x >= baselineRange(1) & x <= baselineRange(2));

% y values for the baseline from peak start and peak end
baseline = linspace(yRange(1), yRange(end), length(xRange));

% Find the peak y
[yMax, idxMax] = max(yRange);

% Find the peak x position
xMax = xRange(idxMax);

% Calculate the height of the peak (above baseline)
height = yMax - baseline(idxMax);

% Find the half-height of the peak
halfmax = height/2 + baseline(idxMax);

% The smallest absolute error between the halfmax and the y value will give
% the intercept
[leftMin, leftMinIdx] = min(abs(halfmax - yRange(1:floor(length(yRange)/2))));
[rightMin, rightMinIdx] = min(abs(halfmax - yRange(floor(length(yRange)/2):end)));

rightMinIdx = rightMinIdx + floor(length(yRange)/2) - 1;

% x values (start and end) of the full width at half maximum
x1 = xRange(leftMinIdx);
x2 = xRange(rightMinIdx);

% Difference is the FWHM
fullWidthHalfMax = abs(x1 - x2);

[fig, ax] = plotXY(x, y, ...
    'XLabel', '{\itλ} (nm)', ...
    'YLabel', '{\itA}', ...
    'XLim', [200 600], ...
    'YLim', [0 1], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'FigureName', 'uvvis');

% Overlay a line showing the FWHM
hold on
plot(ax, [x1 x2], [halfmax halfmax], ...
    LineWidth = 2, ...
    Color = [0.1 0.1 0.1], ...
    LineStyle = "--")

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Save FWHM
saveTable(fullWidthHalfMax, ...
    VariableNames = {'FWHM'}, ...
    SavePath = savePath ...
    )

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)