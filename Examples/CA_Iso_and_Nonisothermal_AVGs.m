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
expName = "CA iso vs non-iso overlay AVG";

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Temperature gradient effect on CO2RR\Revision 1\New or Edited Figures\L-shape\-1.7 0 V L2D 2mm 25.0 15  min 6.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Temperature gradient effect on CO2RR\Revision 1\New or Edited Figures\L-shape\-1.7 0 V L2D 2mm 25.0 15  min 5.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Temperature gradient effect on CO2RR\Revision 1\New or Edited Figures\L-shape\-1.7 0 V L2D 2mm 25.0 15  min 4.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Temperature gradient effect on CO2RR\Revision 1\New or Edited Figures\L-shape\-1.7 0 V L2D 2mm 35.0 15  min 3.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Temperature gradient effect on CO2RR\Revision 1\New or Edited Figures\L-shape\-1.7 0 V L2D 2mm 35.0 15  min 2.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Temperature gradient effect on CO2RR\Revision 1\New or Edited Figures\L-shape\-1.7 0 V L2D 2mm 35.0 15  min 1.txt"
};

% Path to background files (one per line)
bkgPath = {
};

% General parameters
saveToAnalysisFolder = true;

% Plotting options
YScaleFactor = 1e3; 
% offset = [-0.8e-6 -0.5e-6 -1.2e-6];

% Color for the non-isothermal (gradient)
% colors = {
%     [0.1000 0.1000 0.1000]      % dark grey
%     [0.4660 0.6740 0.1880]      % green
%     [0.8290 0.6940 0.1250]      % burnt yellow
%     [0.8000 0.3250 0.0980]      % orange-brown
%     [0.9000 0.0000 0.0000]      % strong red
% };

% Color for isothermal condition
% colors = {
%     [0.1000 0.1000 0.1000]      % dark grey
%     [0.0000 0.2235 0.5500]      % dark blue
%     [0.0000 0.4470 0.7410]      % blue
%     [0.3000 0.6500 0.9200]      % light blue
%     [0.5000 0.8500 0.9900]      % lighter blue
% };

% Color for 3 trials of isothermal and 3 trials of non-isothermal
% colors = {
%     [0.1000 0.1000 0.1000]      % dark grey
%     [0.0000 0.2235 0.5500]      % dark blue
%     [0.0000 0.4470 0.7410]      % blue
%     [0.8290 0.6940 0.1250]      % burnt yellow
%     [0.8000 0.3250 0.0980]      % orange-brown
%     [0.9000 0.0000 0.0000]      % strong red
%     };

% 1 color for iso, 1 color for non-iso 
% colors = {
%     [0.1000 0.1000 0.1000]
%     [0.9000 0.0000 0.0000]
% };
colors = {
    [0.0000 0.4470 0.7410]
    [0.8000 0.3250 0.0980]
    [0.9000 0.0000 0.0000]
};

% Experimental params
% T = [30.0 30.2 30.3];
% pH = 13.7;
% ERHE = @(E) 0.222 + 13.7*0.059 + E;
electrodeDiameter = 0.2; % in cm

%% MAIN 
% Read data
[time, current] = readDataPath(dataPath, 1, 2);

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

% Corrections and adjustments
for i = 1:nFiles
    % potential{i} = potential{i}/1000;

    % current{i} = current{i} - offset(i); % offset data

    % potential{i} = ERHE(potential{i}); % convert potential from Ag/AgCl to RHE

    current{i} = current{i} / (pi * electrodeDiameter^2 / 4);
end

% Avg of first condition
avg1 = mean(cell2mat(current(1:3)), 2);
std1 = std(cell2mat(current(1:3)), 0, 2);

% Avg of second condition
avg2 = mean(cell2mat(current(4:6)), 2);
std2 = std(cell2mat(current(4:6)), 0, 2);

% Avg of third condition
% avg3 = mean(cell2mat(current(7:9)), 2);
% std3 = std(cell2mat(current(7:9)), 0, 2);

averageJ = {avg1; avg2};
% averageJ = {avg1; avg2; avg3};


[fig, ax] = plotXY(time{1}, averageJ, ... 
    XLabel =        '{\itt} (s)', ...
    YLabel =        '{\itj} (mA cm^{−2})', ...
    YLim =          [], ...
    XLim =          [0 600], ...
    XTick =         [], ...
    AspectRatio =   1.2, ...
    PlotWidth =     5, ...
    LineWidth =     1.5, ...
    Color =         colors, ...
    FigureName =    'CA', ...
    YScaleFactor =  YScaleFactor);

l = legend(ax, ...
    {'0'; '10'}, ...
    'Location', 'southeast', ...
    'AutoUpdate', 'off');

addLegendTitle(l, 'Δ{\itT} (°C)', 'top', false)

% l = legend(ax, ...
%     {'0'; '100'; '500'}, ...
%     'Location', 'southeast', ...
%     'AutoUpdate', 'off');
% 
% addLegendTitle(l, '{\it\omega} (min^{−1})', 'top', false)

hold on

% helper that creates a 2N polygon for the band
fillBand = @(t, avg, sd, varargin) ...
    fill([t(:); flipud(t(:))], ...
         [ (avg(:)+sd(:))*YScaleFactor; flipud( (avg(:)-sd(:))*YScaleFactor ) ], ...
         varargin{:}, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'Parent', ax);

% choose face colors that match your two curves (optional)
c1 = colors{1};
c2 = colors{2};
% c3 = colors{3};

fillBand(time{1}, avg1, std1,  c1);
fillBand(time{1}, avg2, std2, c2);
% fillBand(time{1}, avg3, std3, c3);
uistack(findobj(ax,'Type','Patch'),'bottom');   % keep bands behind the lines

% ax.YTick = [];

% legend(ax, ...
%     {'25.0'; '27.0'; '30.0'; '32.0'; '35.0'}, ...
%     'Location', 'southeast')

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
