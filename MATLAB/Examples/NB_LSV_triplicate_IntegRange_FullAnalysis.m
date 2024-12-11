% Data processing for Nile Blue activation energy.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   For documentation, see: github.com/jvhemmer/data-processing/
%   johann.hemmer@louisville.edu
%   29 Aug 2024
clear
close all
clc

%% Basic Parameters
% Experiment name (leave blank to use file name).
expName = 'DPV 1uMNB 5mVps 35C (triplicate)';

% Path to data files (char separated by space, semicolor or new line)
sersPath = { % SERS data
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08292024\rAg1 LSV\2024-08-29 12_01_34 LSV 1uMNB 5mVps 35C (3).csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08292024\rAg1 LSV\2024-08-29 11_53_16 LSV 1uMNB 5mVps 35C (2).csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08292024\rAg1 LSV\2024-08-29 11_47_33 LSV 1uMNB 5mVps 35C (1).csv"
};

lsvPath = { % LSV data
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08282024\rAg4 (1)\DPV 50uMNB 35C.txt"
};

bkgPath = { % SERS background spectra
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08132024\2024-08-13 13_36_03 DC.csv" 
};

lsvBkgPath = { % LSV bkg data
};

% Experiment parameters
fps = 1; % frames per second (from LightField)
scanRate = 0.005; % V/s
CVlimits = [-40 -30];
Range = [568 613];

%% Execution
% Process background spectrum
if not(isempty(bkgPath))
    [~, bkgIntensity] = readSpectra(bkgPath);

    avgBkgIntensity = avgSpectra(bkgIntensity);
end

% Read the data contained in the file
for i = 1:length(sersPath)
    [wavelength{i}, intensity{i}] = readSpectra(sersPath{i});
end
wavelength = wavelength{1};

intcombined = zeros(size(intensity{1}));
for i = 1:length(sersPath)
    intcombined = intcombined + intensity{i};
end
intensity = intcombined / length(sersPath);

% Convert wavelength to Raman shift
ramanShift = wavelengthToRS(wavelength, 636.49);

% Background subtraction
corrIntensity = intensity - avgBkgIntensity;

% Find and integrate the peak in all frames
for frame = 1:size(corrIntensity, 2)
    [area(frame)] = integratePeak(ramanShift, corrIntensity(:,frame), Range);
end

peakArea = area';

% Plot Area vs time and potential
[potential, time] = calculateWaveform(0, -0.6, fps, scanRate, 1);

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

[fig2, ax2] = plotXY(potential, peakArea, ...
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', '{\itA}_{592}', ...
    'FigureName', 'potential_vs_area', ...
    'YLim', [0 max(peakArea)], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5);

yyaxis(ax2, 'right')

[pot, cur] = readData(lsvPath{1}, 1, 2);

if not(isempty(lsvBkgPath))
    [~, bkgCur] = readData(lsvBkgPath{1}, 1,2);

    cur = cur - bkgCur;
end

[~, ~, lin2] = plotXY(pot, cur * 1e6, ...
    'YAxisLocation', 'right', ...
    'Axes', ax2);

lin2.Color = [0.8500 0.3250 0.0980];

ax2.YAxis(1).Color = [0.0000 0.4470 0.7410];
ax2.YAxis(2).Limits = [-70 -5];

ylabel('{\iti} (μA)')

% Plotting potential vs. dA/dt and current
smoothArea = sgolayfilt(peakArea, 2, 13);
der = diff(smoothArea)./diff(time');
% der = sgolayfilt(der, 2, 7);

[fig3, ax3] = plotXY(potential(1:end-1), der, ...
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', 'd{\itA}_{592}/d{\itt}', ...
    'YExponent', 3, ...
    'FigureName', 'potential_vs_der', ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5);

% yticks(ax3, []);

yyaxis(ax3, 'right')

[~, ~, lin3] = plotXY(pot, cur * 1e6, ...
    'YAxisLocation', 'right', ...
    'Axes', ax3);

lin3.Color = [0.8500 0.3250 0.0980];

ax3.YAxis(1).Color = [0.0000 0.4470 0.7410];
ax3.YAxis(2).Color = [0.8500 0.3250 0.0980];
ax3.YAxis(2).Limits = [-70 0];

ylabel('{\iti} (μA)')

% % Time vs derivative
% fullSmoothArea = sgolayfilt(peakArea, 2, 65);
% fullDer = diff(fullSmoothArea)./diff(time(1:end));
% 
% [fig4, ax4] = plotXY(time(1:end-1), fullDer, ...
%     'XLabel', '{\itt} (s)', ...
%     'YLabel', 'd{\itA}_{592}/d{\itt}', ...
%     'FigureName', 'time_vs_der', ...
%     'XLim', [0 max(time)], ...
%     'YAxisLocation', 'left', ...
%     'AspectRatio', 2.4, ...
%     'PlotWidth', 8);
% 
% [~, ~, lin4] = plotXY(0.2:0.2:(time(end)+1), cur, ...
%     'LineStyle', '-', ...
%     'YAxisLocation', 'right', ...
%     'Axes', ax4);
% 
% lin4.Color = [0.8500 0.3250 0.0980];
% 
% ax4.YAxis(1).Color = [0.0000 0.4470 0.7410];
% 
% ylabel('{\iti} (A)')


%% Saving
savePath = createAnalysisFolder(sersPath{1}, expName);

saveAllFigs(savePath, 'fig', 'pdf', 'png')
disp(['Done saving figures at ' savePath '.'])

% Saving the areas
saveTable(potential', peakArea, ... 
    'SavePath', savePath, ...
    'VariableNames', {'Potential (V)', 'Area'}, ...
    'FileName', 'areas.txt');

% Copy files
copyFile(savePath, sersPath, bkgPath)

% Saving a report
saveReport(savePath)