% CV: Plot CVs from data files.
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
expName = 'GCE';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10012024\CV in diff electrodes\GCE (3mm) in 50uM.txt"
};

electrodeArea = 3; % mm
YScaleFactor = 1e6 / ( pi * ( electrodeArea / 10 )^2 / 4 );

cycle = [3];

nFiles = length(dataPath);

pH = 13.7;
ERHE = @(E) 0.222 + 13.7*0.059 + E;

% Reading data
potential = cell([nFiles 1]);
current = cell([nFiles 1]);

for i = 1:nFiles
    [potential{i}, current{i}] = readData(dataPath{i}, 1, 2);

    % potential{i} = ERHE(potential{i});

    if not(isempty(cycle))
        ptemp = splitArray(potential{i}, 3);
        ctemp = splitArray(current{i}, 3);
        potential{i} = ptemp{cycle(i)};
        current{i} = ctemp{cycle(i)};
    end
end

[fig, ax] = plotXY(potential{1}, current{1}, ...
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', '{\itj} (μA/cm^2)', ...
    'XLim', [], ...
    'YLim', [-200 200], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'YScaleFactor', YScaleFactor);
    
if nFiles > 1
    for j = 2:nFiles
    plotXY(potential{j}, current{j}, ...
        'YScaleFactor', YScaleFactor, ...
        'Color', j, ...
        'Axes', ax);
    end
end

% legend(ax, ...
%     {'5 mV/s'; '50 mV/s'}, ...
%     'Location', 'best')

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveFig(fig, 'output', savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)