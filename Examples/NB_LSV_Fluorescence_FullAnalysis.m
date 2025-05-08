% Data processing for Nile Blue activation energy using fluorescence from
% the camera without a spectrometer.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   For documentation, see: github.com/jvhemmer/spec-tbx/
%   johann.hemmer@louisville.edu
%   28 Apr 2025
clear
% close all
clc

%% Basic Parameters
% Experiment name (leave blank to use file name).
expName = '44.4C';

% Path to data files (char separated by space, semicolor or new line)
sersPath = { % optical data
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E13 (half half)\2025-04-20 14_53_34 LSV_5mVps 10uW_laser rough 2 25.5C.csv"
};

lsvPath = { % LSV data
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\2025\04202025\E12 (same as E10, E8), rough, 1uM NB soln\LSV 5mVps 29.7C.txt"
};

bkgPath = { % SERS background spectra
};

lsvBkgPath = { % LSV bkg data
};

% Experiment parameters
fps = 10; % frames per second (from LightField)
scanRate = 0.005; % V/s
% CVlimits = [-40 -30];
ROI = {17:53, 17:53}; % region in the image that will be binned

%% Execution
% Process background spectrum
% if not(isempty(bkgPath))
%     [~, bkgIntensity] = readSpectra(bkgPath);
% 
%     avgBkgIntensity = avgSpectra(bkgIntensity);
% end

% Read the data contained in the file
for i = 1:length(sersPath)
    [frame{i}, image{i}] = readCameraMatrix(sersPath{i});
end
frame = frame{1};

intensity = cell([length(sersPath)]);
for i = 1:length(sersPath)
    intensity{i} = zeros([length(image{i}{1}) 1]);
    for j = 1:length(frame)
        intensity{i}(j) = sum(image{i}{j}(ROI{1},ROI{2}), "all");
    end
end

intensities = intensity;

combinedIntensity = zeros([length(intensity{1}) 1]);
for i = 1:length(sersPath)
    combinedIntensity = combinedIntensity + intensity{i};
end

averageIntensity = combinedIntensity / length(sersPath);

intensity = averageIntensity;

% Plot Area vs time and potential
[potential, time] = calculateWaveform(0, -0.6, fps, scanRate, 1);

[fig1, ax1] = plotXY(time, intensity, ...
    'XLabel', '{\itt} (s)', ...
    'YLabel', '{\itI}', ...
    'FigureName', 'time_vs_intensity', ...
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
hold on
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

% [fig2, ax2] = plotXY(potential, intensity, ...
%     'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
%     'YLabel', '{\itI}', ...
%     'FigureName', 'potential_vs_area', ...
%     'YLim', [min(intensity) max(intensity)], ...
%     'AspectRatio', 1.2, ...
%     'PlotWidth', 5);
% 
% yyaxis(ax2, 'right')
% 
% [pot, cur] = readData(lsvPath{1}, 1, 2);
% 
% if not(isempty(lsvBkgPath))
%     [~, bkgCur] = readData(lsvBkgPath{1}, 1,2);
% 
%     cur = cur - bkgCur;
% end
% 
% [~, ~, lin2] = plotXY(pot, cur * 1e6, ...
%     'YAxisLocation', 'right', ...
%     'Axes', ax2);
% 
% lin2.Color = [0.8500 0.3250 0.0980];
% 
% ax2.YAxis(1).Color = [0.0000 0.4470 0.7410];
% % ax2.YAxis(2).Limits = [-70 -5];
% 
% ylabel('{\iti} (μA)')
% 
% % Plotting potential vs. dA/dt and current
% smoothArea = sgolayfilt(intensity, 2, 13);
% der = diff(smoothArea)./diff(time');
% % der = sgolayfilt(der, 2, 7);
% 
% [fig3, ax3] = plotXY(potential(1:end-1), der, ...
%     'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
%     'YLabel', 'd{\itI}/d{\itt}', ...
%     'YExponent', 3, ...
%     'FigureName', 'potential_vs_der', ...
%     'AspectRatio', 1.2, ...
%     'PlotWidth', 5);
% 
% % yticks(ax3, []);
% 
% yyaxis(ax3, 'right')
% 
% [~, ~, lin3] = plotXY(pot, cur * 1e6, ...
%     'YAxisLocation', 'right', ...
%     'Axes', ax3);
% 
% lin3.Color = [0.8500 0.3250 0.0980];
% 
% ax3.YAxis(1).Color = [0.0000 0.4470 0.7410];
% ax3.YAxis(2).Color = [0.8500 0.3250 0.0980];
% ax3.YAxis(2).Limits = [-70 0];
% 
% ylabel('{\iti} (μA)')

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


% %% Saving
% savePath = createAnalysisFolder(sersPath{1}, expName);
% 
% saveAllFigs(savePath, 'fig', 'png')
% disp(['Done saving figures at ' savePath '.'])
% 
% % Saving the areas
% saveTable(potential', intensity, ... 
%     'SavePath', savePath, ...
%     'VariableNames', {'Potential (V)', 'Intensity'}, ...
%     'FileName', 'areas.txt');
% 
% % Copy files
% copyFile(savePath, sersPath, bkgPath)
% 
% % Saving a report
% saveReport(savePath)