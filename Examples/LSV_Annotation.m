% LSV: Plot Linear Sweep Voltammograms from data files.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   28 Aug 2024
clear
close
clc

%% BASIC PARAMETERS
% Experiment name (comment out or leave blank to use file name)
expName = "Gradient overlay (Bath=25)";

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Data from Amin\ES CA Surafce\ES 25 HB 25  10 min Onset at -1.7 V r.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Data from Amin\ES CA Surafce\ES 27 HB 25  10 min Onset at -1.7 V.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Data from Amin\ES CA Surafce\ES 30 HB 25  10 min Onset at -1.7 V.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Data from Amin\ES CA Surafce\ES 32 HB 25  10 min Onset at -1.7 V.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Data from Amin\ES CA Surafce\ES 35 HB 25  10 min Onset at -1.7 V.txt"
};

% Path to background files (one per line)
bkgPath = {
};

% Plotting options
YScaleFactor = 1; 
% offset = [-0.8e-6 -0.5e-6 -1.2e-6];

% Experimental params
% T = [30.0 30.2 30.3];
% pH = 13.7;
% ERHE = @(E) 0.222 + 13.7*0.059 + E;

%% MAIN 
% Read data
[potential, current] = readDataPath(dataPath, 1, 2);

nFiles = length(dataPath); % number of files

% Data processing (comment out what is not necessary)

% Process background 
if not(isempty(bkgPath))
    nBkg = length(bkgPath);
    bkgCurrent = cell([nFiles 1]);
    for i = 1:nBkg
        [~, bkgCurrent{i}] = readData(bkgPath{i}, 1, 2);

        current{i} = current{i} - bkgCurrent{i}; % Subtract background current
    end
end

for i = 1:nFiles
    % potential{i} = potential{i}/1000;
    % current{i} = current{i} - offset(i); % offset data

    % potential{i} = ERHE(potential{i}); % convert potential from Ag/AgCl to RHE
end

[fig, ax] = plotXY(potential, current, ... 
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', '{\iti} (μA)', ...
    'YLim', [], ...
    'XLim', [], ...
    'XTick', [], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'LineWidth', 1.5, ...
    'NumSize', 16, ...
    'FontSize', 18, ...
    'FigureName', 'LSV', ...
    'YScaleFactor', YScaleFactor);

% ax.YTick = [];

legend(ax, ...
    {'25.0'; '27.0'; '30.0'; '32.0'; '35.0'}, ...
    'Location', 'southeast')

% Annotation in the plot
% Tm = mean(T);
% Ts = std(T);
% 
% formatSpec = '%.1f';
% str = append("{\itT} = ", num2str(Tm,formatSpec), " ± ", num2str(Ts,formatSpec), " °C");
% an = annotation(fig, 'textbox', String=str, FitBoxToText='on', LineWidth=1.5, FontName='Arial', FontSize=16);
% an.Units = 'inches';
% an.Position = [ax.Position(1) + 0.15, ax.Position(3) - an.Position(3) - 0.2, an.Position(3), an.Position(4)];

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveFig(fig, 'output', savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)
