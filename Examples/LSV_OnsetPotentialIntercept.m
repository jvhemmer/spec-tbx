% LSV_OnsetPotentialIntercept:  Plot Linear Sweep Voltammograms and
% calculate the onset potential using the intercept method.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   28 Aug 2024
clear
close all
clc

%% BASIC PARAMETERS
% Experiment name (comment out or leave blank to use file name)
expName = "Isothermal trial 6 onset potential new";

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Submission 2 (ACS)\Repeated LSV\06232025\HB 25.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Submission 2 (ACS)\Repeated LSV\06232025\HB 27.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Submission 2 (ACS)\Repeated LSV\06232025\HB 30.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Submission 2 (ACS)\Repeated LSV\06232025\HB 32.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Submission 2 (ACS)\Repeated LSV\06232025\HB 35.txt"
};

% Path to background files (one per line)
bkgPath = {
};

% Plotting options
YScaleFactor = 1e3; 
% offset = [-0.8e-6 -0.5e-6 -1.2e-6];

% Experimental params
% pH = 13.7;
% ERHE = @(E) 0.222 + 13.7*0.059 + E;
electrodeDiameter = 0.2; % in cm
filter = {[0.015 2.5]; [0.0047 2.5]; [0.0047 2.5]; [0.0047 2.5]; [0.0047 2.5]};
solResistance = [12.4 10.5 11.2 10.8 10.6];
ETRange = [-0.9 -0.5];
MTRange = [-1.5 -1.4];

% Color for the non-isothermal (gradient)
% colors = {
%     [0.1000 0.1000 0.1000]      % dark grey
%     % [0.0000 0.4470 0.7410]      % blue
%     [0.4660 0.6740 0.1880]      % green
%     [0.8290 0.6940 0.1250]      % burnt yellow
%     [0.8000 0.3250 0.0980]      % orange-brown
%     [0.9000 0.0000 0.0000]      % strong red
% };

% Color for isothermal condition
colors = {
    [0.1000 0.1000 0.1000]      % dark grey
    [0.0000 0.2235 0.5500]      % dark blue
    [0.0000 0.4470 0.7410]      % blue
    [0.3000 0.6500 0.9200]      % light blue
    [0.5000 0.8500 0.9900]      % lighter blue
};


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

% Correction and conversions
for i = 1:nFiles
    % potential{i} = potential{i}/1000; % convert from mV
    potential{i} = potential{i} - (current{i} * solResistance(i)); % iR correction
    % current{i} = current{i} - offset(i); % offset data
    % time = timeFromCV(potential{i}, 0.005); % calculate time for filtering
    % current{i} = filterCV(time, current{i}, filter{i}, "filterOrder", 2); % apply filter
    % potential{i} = ERHE(potential{i}); % convert potential from Ag/AgCl to RHE
    current{i} = current{i} / (pi * electrodeDiameter^2 / 4); % calculate current density
end

% Calculate onset potential
ETLimitedCurrent{i} = cell([nFiles 1]);
MTLimitedCurrent{i} = cell([nFiles 1]);
Eonset = zeros([nFiles 1]);
for i = 1:nFiles
    ETMask = potential{i} >= min(ETRange) & potential{i} <= max(ETRange);
    ETPotentialRange = potential{i}(ETMask);
    ETCurrentRange = current{i}(ETMask);
    p1 = polyfit(ETPotentialRange, ETCurrentRange, 1);
    ETLimitedCurrent{i} = polyval(p1, potential{i});

    MTMask = potential{i} >= min(MTRange) & potential{i} <= max(MTRange);
    MTPotentialRange = potential{i}(MTMask);
    MTCurrentRange = current{i}(MTMask);
    p2 = polyfit(MTPotentialRange, MTCurrentRange, 1);
    MTLimitedCurrent{i} = polyval(p2, potential{i});

    pdiff = p1 - p2;
    intercept = roots(pdiff);
    Eonset(i) = real(intercept);
end

for i = 1:nFiles
    plotXY(potential{i}, current{i}, ... 
        'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
        'YLabel', '{\itj} (mA cm^{−2})', ...
        'YLim', [], ...
        'XLim', [-1.7 -0.5], ...
        'XTick', [-1.7 -1.5 -1.3 -1.1 -0.9 -0.7 -0.5], ...
        'Color', colors{i}, ...
        'AspectRatio', 1.2, ...
        'LineWidth', 1.5, ...
        'PlotWidth', 5, ...
        'FigureName', append('File ', num2str(i)), ...
        'YScaleFactor', YScaleFactor);

    plotXY(potential{i}, 1e3*ETLimitedCurrent{i}, ...
        Color='k', ...
        LineStyle='--', ...
        LineWidth=1.5, ...
        Axes=gca);

    plotXY(potential{i}, 1e3*MTLimitedCurrent{i}, ...
        Color='k', ...
        LineStyle='--', ...
        LineWidth=1.5, ...
        Axes=gca);
end

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Save onset
saveTable(Eonset, ...
    VariableNames = {'Eonset (V)'}, ...
    SavePath = savePath ...
    )

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)
