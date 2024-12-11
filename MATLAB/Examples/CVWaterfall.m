% CVWaterfall: Waterfall plot for CV-Raman experiment.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   For documentation, see: github.com/jvhemmer/data-processing/
%   johann.hemmer@louisville.edu
%   12 Nov 2024
clear
close all
clc

%% Basic Parameters
% Experiment name (leave blank to use file name).
expName = 'Waterfall 0.005 mM NB';

% Path to data files (char separated by space, semicolor or new line)
dataPath = { % 1st line: SERS data. 2nd line: correlated CV data
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08262024\0.005mM NB in soln\2024-08-26 14_37_59 rAg4 5mVps CV0.2-0.csv" 
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08262024\0.005mM NB in soln\CV 0.2 to -0.6 5mVps.txt"
};

bkgPath = { % SERS background spectra
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\08132024\2024-08-13 13_36_03 DC.csv"
};

% Raman parameters
laserWavelength = 636.49;
fps = 1; % frames per second (from LightField)

% EC parameters
E0 = 0.2;
E1 = -0.6;
scanRate = 0.005; % V/s
segments = 6;
CVlimits = [-10 6];

% Style (FIX LATER)
fontName = "Arial";
fontSize = 20;
numSize = 18;
lineWidth = 2;
color = [0 0.4470 0.7410];
plotWidth = 8; % inches
aspectRatio = 2.4; % lenght ÷ height

%% Execution
% Read the data contained in the file
[wavelength, intensity] = readSpectra(dataPath{1});

% Process background spectrum (if used)
if not(isempty(bkgPath{1}))
    [~, bkgIntensity] = readSpectra(bkgPath);

    avgBkgIntensity = avgSpectra(bkgIntensity);

    % Background subtraction
    intensity = intensity - avgBkgIntensity;
end

% Convert wavelength to Raman shift
ramanShift = wavelengthToRS(wavelength, laserWavelength);

% Plot Area vs time and potential
[potential, time] = calculateWaveform(E0, E1, fps, scanRate, segments);

% Create figure and axes objects
fig = figure("Name", "waterfall");
ax = subplot(1,2,1);

% Plot mesh on the axes
sur = mesh(ax, ...
    ramanShift, time, intensity');

% View from the top (will be flat instead of 3D)
view(ax, 2)

% Color scheme of the mesh, 'jet' is rainbow
colormap('jet')

xlabel(ax, ...
    "Raman shift (cm^{−1})", ...
    'FontName', fontName, ...
    'FontSize', fontSize, ...
    'Interpreter', 'tex')

ylabel(ax, ...
    "{\itt} (s)", ...
    'FontName', fontName, ...
    'FontSize', fontSize, ...
    'Interpreter', 'tex')

set(fig, ...
    'Theme', 'light', ...
    'Units', 'inches')

set(ax, ...
    'FontName', fontName, ...
    'FontSize', numSize, ...
    'LineWidth', lineWidth, ...
    'TickLabelInterpreter', 'tex', ...
    'XLimitMethod', 'tight', ...
    'YLimitMethod', 'tight', ...
    'Box', 'on', ...
    'Units', 'inches', ...
    'Layer', 'top', ...
    'YDir', 'reverse')

grid off

% Setup the colorbar
h = colorbar(ax, ...
    'northoutside', ...
    'FontSize', fontSize, ...
    'LineWidth', lineWidth);

htitle = get(h, 'Title'); % getting title handle
htitle.FontSize = fontSize; % changing font size of label
htitle.String = "Intensity (counts)"; % adding title to label

% hAxes = findobj(gcf,"Type","axes");
% hAxes(1).ColorScale = "log";
% 
% h.Ticks = 1e4;
% ax.ColorScale = "log";

%% Ploting potential step
ax2 = subplot(1,2,2);

lin = plot(ax2, ...
    potential, time, ...
    'Color', color, ...
    'LineWidth', lineWidth);

xlabel(ax2, ...
    'E (V)', ...
    'FontName', fontName, ...
    'FontSize', fontSize, ...
    'Interpreter', 'tex')

ylabel(ax2, ...
    '{\itt} (s)', ...
    'FontName', fontName, ...
    'FontSize', fontSize, ...
    'Interpreter', 'tex')

set(ax2, ...
    'FontName', fontName, ...
    'FontSize', numSize, ...
    'LineWidth', lineWidth, ...
    'TickLabelInterpreter', 'tex', ...
    'YAxisLocation', 'right', ...
    'XLimitMethod', 'tight', ...
    'YLimitMethod', 'tight', ...
    'YDir', 'reverse', ...
    'Box', 'on', ...
    'Units', 'inches')

ax2.XLim = [min(potential) max(potential)];
ax2.XTick = [-1.8 -1.2 -0.6];

%% Arranging the position of the plots correctly
% Configure exact position of the axes if 'plotWidth' exists
if (exist('plotWidth', 'var') || exist('aspectRatio', 'var'))
    ax.PositionConstraint = 'OuterPosition';

    plotHeight = plotWidth/aspectRatio;

    ax.Position([3 4]) = [plotWidth plotHeight];

    h.Units = 'inches';
    htitle.Units = 'inches';
    
    htitle.Position(1) = plotWidth/2;
    htitle.Position(2) = 0.7;
    
    ax.OuterPosition([1 2]) = [0 0];

    ax2.Units = 'inches';
    ax2.Position(1) = ax.OuterPosition(3) + h.Position(4);
    ax2.Position(2) = ax.Position(2);
    ax2.Position(4) = ax.Position(4);

    fig.Position([3 4]) = ax.OuterPosition([3 4]);
    fig.Position(3) = fig.Position(3) + ax2.OuterPosition(3);
    fig.Position(4) = fig.Position(4) + htitle.Position(2) + h.Position(4);
end

%% Saving
savePath = createAnalysisFolder(dataPath{1}, expName);

saveAllFigs(savePath, 'fig', 'png') % add "pdf" as an argument for vector 
% output. WARNING: might take a very long time to compile
disp(['Done saving figures at ' savePath '.'])

% Copy files
copyFile(savePath, dataPath, bkgPath)

% Saving a report
saveReport(savePath)