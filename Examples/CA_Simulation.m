% CA: Plot chronoamperograms from data files.
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
expName = "CA 473 nm";

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\Box\Johann Hemmer Data\Plasmon-induced migration (Amin 3rd project)\Manuscript Figures\3\B\Isothermal.txt"
"C:\Users\jhemmer\Box\Johann Hemmer Data\Plasmon-induced migration (Amin 3rd project)\Manuscript Figures\3\B\Non-isothermal 473 nm.txt"
"C:\Users\jhemmer\Box\Johann Hemmer Data\Plasmon-induced migration (Amin 3rd project)\Manuscript Figures\3\B\Non-isothermal + migration 473 nm.txt"
};

% General parameters
saveToAnalysisFolder = false;

% Colors for green laser
% colors = {
%     [0.1000 0.1000 0.1000]      % dark grey
%     [1.0000 0.0000 0.0000]      % pure red
%     [0.4660 0.6740 0.1880]      % green
% };

% Colors for blue laser
colors = {
    [0.1000 0.1000 0.1000]      % dark grey
    [1.0000 0.0000 0.0000]      % pure red
    [0.0000 0.0000 1.0000]      % pure blue
};

%% MAIN 
% Read data
[time, currentdensity] = readDataPath(dataPath, 1, 2);

nFiles = length(dataPath); % number of files

[fig, ax] = plotXY(time, currentdensity, ... 
    XLabel =        '{\itt} (s)', ...
    YLabel =        '{\itj} (mA cm^{−2})', ...
    YLim =          [-1 0], ...
    XLim =          [0 600], ...
    XTick =         [], ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    LineWidth =     2, ...
    Color =         colors, ...
    FigureName =    'CA');

leg = legend(ax, ...
    {'{\itT}_{surf} = 22.7 °C'; '{\itT}_{surf} = 29.4 °C'; '{\itT}_{surf} = 29.4 °C, {\itu}_{surf} = 0.643 μm s^{−1}'}, ...
    'Location', 'southeast');

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
