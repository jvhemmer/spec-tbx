% Plot simulated data of E-field vs. z.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   14 Oct 2024
clear
close
clc

%% BASIC PARAMETERS
% Experiment name (comment out or leave blank to use file name)
expName = "E-field vs z in dimer";

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\Box\Johann Hemmer Data\Plasmon-induced migration (Amin 3rd project)\COMSOL\10 Oct\20251010\Efield away from surface in dimer wl=473.txt"
"C:\Users\jhemmer\Box\Johann Hemmer Data\Plasmon-induced migration (Amin 3rd project)\COMSOL\10 Oct\20251010\Efield away from surface in dimer wl=532.txt"
};

% General parameters
saveToAnalysisFolder = true;

% Colors 
colors = {
    [0, 0.4470, 0.7410]         % blue
    [0 0.5 0]                   % dark green
};

%% MAIN 
% Read data
[z, E] = readDataPath(dataPath, 1, 2);

nFiles = length(dataPath); % number of files

% Transformations/correction on the data
for i = 1:nFiles
    z{i} = -z{i}; 
    E{i} = E{i} .* 1e-3; % Convert to kV/m 
end

[fig, ax] = plotXY(z, E, ... 
    XLabel =        '{\itz} (nm)', ...
    YLabel =        '|{\it\bfE}| (kV/m)', ...
    YLim =          [], ...
    XLim =          [100 200], ...
    XTick =         [], ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    LineWidth =     2, ...
    Color =         colors, ...
    FigureName =    'plot');

leg = legend(ax, ...
    {'473 nm'; '532 nm'}, ...
    'Location', 'northwest');

ax.XDir = 'reverse';

% addLegendTitle(l, 'Δ{\itT} (°C)', 'top', false)

% legend(ax, ...
%     {'Δ{\itT} = 0'; 'Δ{\itT} = 0'; 'Δ{\itT} = 0'; 'Δ{\itT} = 10'; 'Δ{\itT} = 10'; 'Δ{\itT} = 10'}, ...
%     'Location', 'southeast')

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
if saveToAnalysisFolder == true
    % Creating folder to save analysis
    savePath = createAnalysisFolder(dataPath{1}, expName);
    
    % Copy files
    if isfile(dataPath{1})
        copyFile(savePath, dataPath)
    end
else
    savePath = fileparts(dataPath{1});
end

% Saving figures
saveFig(fig, 'output', savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Save workspace
save(append(savePath, filesep, append(expName,'_workspace.mat')))
