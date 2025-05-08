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
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\01. EC-SERS\Data\Nile Blue Activation Energy\08262024\0.005mM NB in soln\2024-08-26 14_37_59 rAg4 5mVps CV0.2-0.csv" 
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\01. EC-SERS\Data\Nile Blue Activation Energy\08262024\0.005mM NB in soln\CV 0.2 to -0.6 5mVps.txt"
};

bkgPath = { % SERS background spectra
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\01. EC-SERS\Data\Nile Blue Activation Energy\08132024\2024-08-13 13_36_03 DC.csv"
};

% Experiment parameters
fps = 1; % frames per second (from LightField)
scanRate = 0.005; % V/s
segments = 6;
cycle = 1; % which cycle will be plotted

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
ramanShift = wavelengthToRS(wavelength, 636.49);

% Background subtraction
corrIntensity = intensity - avgBkgIntensity;

% Find and integrate the peak in all frames
[peakPos, peakArea, QC] = integrateFrameByFrame( ...
    ramanShift, corrIntensity, ...
    'MinimumSNR', 3, ...
    'PolynomialDegree', 2, ...
    'WindowSize', 13, ...
    'PeakRange', [520 640], ...
    'NoiseRange', [800 900], ...
    'TargetPeakPos', 592, ...
    'Visible', 'on');

% Plot Area vs time and potential
[potential, time] = calculateWaveform(0.2, -0.6, fps, scanRate, segments);

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
    'YLim', [0 max(peakArea)], ...
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
ax2.YAxis(2).Limits = [-10 5];

ylabel('{\iti} (μA)')

% Plotting potential vs. dI/dt and current

smoothArea = sgolayfilt(peakAreaSplit{cycle}, 4, 33);
% der = smoothArea;
der = diff(smoothArea)./diff(time(1:320)');
smoothDer = sgolayfilt(der, 4, 23);

[fig3, ax3] = plotXY(potentialSplit{cycle}(1:end-1), smoothDer, ...
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
ax3.YAxis(2).Limits = [-10 5];

ylabel('{\iti} (μA)')

%% Saving
savePath = createAnalysisFolder(dataPath{1}, expName);

saveAllFigs(savePath, 'fig', 'pdf', 'png')
disp(['Done saving figures at ' savePath '.'])

% Saving the areas
saveTable(peakPos, peakArea, ... 
    'SavePath', savePath, ...
    'VariableNames', {'Peak Raman Shift (cm-1)', 'Area'}, ...
    'FileName', 'areas.txt');

% Copy files
copyFile(savePath, dataPath, bkgPath)

% Saving a report
saveReport(savePath)