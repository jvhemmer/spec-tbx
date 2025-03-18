% NB_FullAnalysis: Data processing for Nile Blue activation energy.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   For documentation, see: github.com/jvhemmer/data-processing/
%   johann.hemmer@louisville.edu
%   15 Mar 2024
clear
close all
clc

%% Basic Parameters
% Experiment name (leave blank to use file name).
expName = '';

% Path to data files (char separated by space, semicolor or new line)
dataPath = { % 1st line: SERS data. 2nd line: correlated CV data
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\02142025\2025-02-14 15_40_49 E3 (rough) CV 5mVps 10FPS.csv" 
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\02142025\E3 (rough) CV 5mVps.txt"};

bkgPath = { % SERS background spectra
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\02142025\2025-02-14 13_34_09 DC.csv"
};

% Experiment parameters
fps = 10; % frames per second (from LightField)
scanRate = 0.005; % V/s
segments = 6;
cycle = 1; % which cycle will be plotted
CVlimits = [];
Range = [568 613];

%% Execution
% Process background spectrum
if not(isempty(bkgPath{1}))
    [~, bkgIntensity] = readSpectra(bkgPath);

    avgBkgIntensity = avgSpectra(bkgIntensity);
end

% dataPath{iFile} = char(dataPath{iFile}); % using cell for backwards compatibility

% Read the data contained in the file
[wavelength, intensity] = readSpectra(dataPath{1});

% Convert wavelength to Raman shift
ramanShift = wavelengthToRS(wavelength, 636.551);

% Background subtraction
corrIntensity = intensity - avgBkgIntensity;

% Find and integrate the peak in all frames
for frame = 1:size(corrIntensity, 2)
    [area(frame)] = integratePeak(ramanShift, corrIntensity(:,frame), Range);
end

peakArea = area';

% Plot Area vs time and potential
[potential, time] = calculateWaveform(0, -0.6, fps, scanRate, segments);

[fig1, ax1] = plotXY(time, peakArea, ...
    'XLabel', '{\itt} (s)', ...
    'YLabel', '{\itA}_{592}', ...
    'FigureName', 'time_vs_area', ...
    'XLim', [0 max(time)], ...
    'YAxisLocation', 'left', ...
    'AspectRatio', 2.4, ...
    'PlotWidth', 8);

[~, ~, lin1] = plotXY(time, potential, ...
    'LineStyle', '--', ...
    'YAxisLocation', 'right', ...
    'Axes', ax1);

lin1.Color = [0.8500 0.3250 0.0980];

ax1.YAxis(1).Color = [0.0000 0.4470 0.7410];

ylabel('{\itE} (V vs. Ag/AgCl)')

% Plotting smooth area curve
% smoothArea = sgolayfilt(peakArea, 3, 33);
% 
% [fig3, ax3] = plotXY(potential, smoothArea, ...
%     'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
%     'YLabel', 'Area', ...
%     'FigureName', 'potential_vs_smoothArea', ...
%     'YLim', [0 max(smoothArea)], ...
%     'AspectRatio', 1.2, ...
%     'PlotWidth', 5);

% Plotting potential vs area and current
potentialSplit = splitArray(potential, 3);
peakAreaSplit = splitArray(peakArea, 3);

[fig2, ax2] = plotXY(potentialSplit{cycle}, peakAreaSplit{cycle}, ...
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', '{\itA}_{592}', ...
    'FigureName', 'potential_vs_area', ...
    'YLim', [0 max(peakAreaSplit{cycle})], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5);

yyaxis(ax2, 'right')

[pot, cur] = readData(dataPath{2}, 1, 2);
potSplit = splitArray(pot, 3);
curSplit = splitArray(cur, 3);

[~, ~, lin2] = plotXY(potSplit{cycle}, curSplit{cycle} * 1e6, ...
    'YAxisLocation', 'right', ...
    'Axes', ax2);

lin2.Color = [0.8500 0.3250 0.0980];

ax2.YAxis(1).Color = [0.0000 0.4470 0.7410];
% ax2.YAxis(2).Limits = CVlimits;

ylabel('{\iti} (μA)')

% Plotting potential vs. dA/dt and current
smoothArea = mirroredSGolayFilt(peakAreaSplit{cycle}, 2, 649);
der = diff(smoothArea)./diff(time(1:length(smoothArea))');
% der = sgolayfilt(der, 2, 7);

[fig3, ax3] = plotXY(potentialSplit{cycle}(1:end-1), der, ...
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', 'd{\itA}_{592}/d{\itt}', ...
    'YExponent', 3, ...
    'FigureName', 'potential_vs_der', ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5);

% yticks(ax3, []);

yyaxis(ax3, 'right')

[~, ~, lin3] = plotXY(potSplit{cycle}, curSplit{cycle} * 1e6, ...
    'YAxisLocation', 'right', ...
    'Axes', ax3);

lin3.Color = [0.8500 0.3250 0.0980];

ax3.YAxis(1).Color = [0.0000 0.4470 0.7410];
ax3.YAxis(2).Color = [0.8500 0.3250 0.0980];
% ax3.YAxis(2).Limits = CVlimits;

ylabel('{\iti} (μA)')


% Time vs derivative
fullSmoothArea = mirroredSGolayFilt(peakArea, 2, 649);
fullDer = diff(fullSmoothArea)./diff(time(1:end));

[fig4, ax4] = plotXY(time(1:end-1), fullDer, ...
    'XLabel', '{\itt} (s)', ...
    'YLabel', 'd{\itA}_{592}/d{\itt}', ...
    'FigureName', 'time_vs_der', ...
    'XLim', [0 max(time)], ...
    'YAxisLocation', 'left', ...
    'AspectRatio', 2.4, ...
    'PlotWidth', 8);

curPoints = length(cur);
curSamplingRate = curPoints / time(end);
curSamplingTime = 1/curSamplingRate;
curTime = curSamplingTime:curSamplingTime:time(end);

[~, ~, lin4] = plotXY(curTime, cur, ...
    'LineStyle', '-', ...
    'YAxisLocation', 'right', ...
    'Axes', ax4);

lin4.Color = [0.8500 0.3250 0.0980];

ax4.YAxis(1).Color = [0.0000 0.4470 0.7410];

ylabel('{\iti} (A)')


%% Saving
savePath = createAnalysisFolder(dataPath{1}, expName);

saveAllFigs(savePath, 'fig', 'png')
disp(['Done saving figures at ' savePath '.'])

% Saving the areas
% saveTable(peakPos, peakArea, ... 
%     'SavePath', savePath, ...
%     'VariableNames', {'Peak Raman Shift (cm-1)', 'Area'}, ...
%     'FileName', 'areas.txt');

% Copy files
copyFile(savePath, dataPath, bkgPath)

% Saving a report
saveReport(savePath)