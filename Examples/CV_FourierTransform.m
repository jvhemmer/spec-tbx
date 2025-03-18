% CV_FourierTransform: Plot CVs and their FTs from data files.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   26 Feb 2025
clear
close all
clc

%% Basic Parameters
% Experiment name (comment out or leave blank to use file name)
expName = 'E2 (rough step2 only, unbuff coupling) CV 50mVps, not filtered';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\02282025\E2 (rough step2 only, unbuffered coupling) CV 50mVps.txt"
};

scanRate = 0.05; % V/s
cycles = 3;

electrodeDiameter = 2; % mm
% YScaleFactor = 1e6 / ( pi * ( electrodeDiameter / 10 )^2 / 4 );
YScaleFactor = 1e6;

cycle = [1];

nFiles = length(dataPath);

pH = 13.7;
ERHE = @(E) 0.222 + pH*0.059 + E;

% Reading data
potential = cell([nFiles 1]);
current = cell([nFiles 1]);
FTcurrent = cell([nFiles 1]);

for i = 1:nFiles
    [potential{i}, current{i}] = readData(dataPath{i}, 1, 2);

    % potential{i} = ERHE(potential{i});

    if not(isempty(cycle))
        ptemp = splitArray(potential{i}, cycles);
        ctemp = splitArray(current{i}, cycles);
        potential{i} = ptemp{cycle(i)};
        current{i} = ctemp{cycle(i)};
    end

    time = timeFromCV(potential{1}, scanRate);

    frequencyStep = 1/(time(2) - time(1));

    % d = designfilt('bandstopiir', 'FilterOrder', 2, 'HalfPowerFrequency1',9, 'HalfPowerFrequency2',11,'SampleRate', frequencyStep);
    % current{i} = filtfilt(d, current{i});
    % 
    % d2 = designfilt('bandstopiir', 'FilterOrder', 2, 'HalfPowerFrequency1',19, 'HalfPowerFrequency2',21,'SampleRate', frequencyStep);
    % current{i} = filtfilt(d2, current{i});

    FTcurrent{i} = abs(fft(detrend(current{i})));

    freqs = (0:length(FTcurrent{i}) - 1) * frequencyStep / length(FTcurrent{i});

    FTcurrent{i} = FTcurrent{i}/length(freqs);
end

[fig, ax] = plotXY(potential, current, ...
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', '{\iti} (μA)', ...
    'XLim', [], ...
    'YLim', [], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'YScaleFactor', YScaleFactor, ...
    'FigureName', 'CV');

[fig2, ax2] = plotXY(freqs, (FTcurrent{1}), ...
    'XLabel', 'ƒ (Hz)', ...
    'YLabel', '{\itF}(ƒ) (μA s)', ...
    'XLim', [3 freqs(end)/2], ...
    'YLim', [], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'YScaleFactor', 1, ...
    'FigureName', 'FourierTransform');

% legend(ax, ...
%     {'5 mV/s'; '50 mV/s'}, ...
%     'Location', 'best')

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)