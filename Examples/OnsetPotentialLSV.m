% LSV: Calculate the onset potential from LSV data using the third
% derivative method.
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
expName = "N4 Dark 5mVps onset";

% Path to data file (one only)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\08. Internal\Colin\LSV Trials through 04112025\Raw Data from New Trials\N4\Dark\5 mVps.txt"
};

% Path to background file (one or none)
bkgPath = {
};

% Plotting options
YScaleFactor = 1; 

% Parameters
expectedRange = [-0.4 -0.2]; % Range expected to find the onset
xConversionFactor = 1e-3;
% pH = 13.7;
% ERHE = @(E) 0.222 + 13.7*0.059 + E;

%% Reading data 

[potential, current] = readDataPath(dataPath, 1, 2);

x = potential{1};
y = current{1};

%% Data processing (comment out what is not necessary)

% Process background 
if not(isempty(bkgPath))
    bkg = readData(bkgPath{1}, 2);

    y = y - bkg; % Subtract background current
end

x = x * xConversionFactor;

% x = ERHE(x); % convert potential from Ag/AgCl to RHE

idxRange = x >= min(expectedRange) & x <= max(expectedRange);

xRange = x(idxRange);
yRange = y(idxRange);

thirdDer = nDerivative(xRange, yRange, 3);

[~, idx] = max(thirdDer);

onset = xRange(idx);

%% Plotting

[fig, ax] = plotXY(x, y, ... 
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', '{\iti} (mA)', ...
    'YLim', [], ...
    'XLim', [-1 0], ...
    'XTick', [], ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'FigureName', 'LSV', ...
    'Color', [0.1000 0.1000 0.1000], ...
    'YScaleFactor', YScaleFactor);

hold on

plot(ax, [onset onset], ax.YLim, ...
    LineWidth = 2, ...
    Color='r')

% ax.YTick = [];

% legend(ax, ...
%     {'Dark'; 'Light'}, ...
%     'Location', 'southeast')

%% Saving

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveFig(fig, 'output', savePath, 'fig', 'png', 'pdf')

% Save onset potential
saveTable(onset, ...
    VariableNames = {'Onset potential'}, ...
    SavePath = savePath ...
    )

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)
