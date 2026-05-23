% Plot the same type of plot with data from the same file containing 
% different conditions to be overlaid.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   2 Nov 2025
clear
close
clc

%% EDIT HERE
% Experiment name (comment out or leave blank to use file name)
expName = 'ORR 1e-3k0 (Au sim)';

% Path to data files (one per line)
dataPath = "C:\Users\jhemmer\Box\Johann Hemmer Data\ORR\2025\11022025\ORR 1e-3k0.txt";

% General parameters
saveToAnalysisFolder = true;
x0 = 0.3; % first value of x, which repeats for every new condition
YScaleFactor = 1;

%% PROCESSING
% Reading data
data = readmatrix(dataPath);

x = data(:, 1);
y = data(:, 2);

% Find all indices that a new dataset starts
idx = find(x == x0);
idx = [idx; length(x)+1];

nDatasets = length(idx)-1;

% Split data into component datasets
dataset = cell(nDatasets, 1);
for i = 1:nDatasets
    dataset{i} = [x(idx(i):idx(i+1)-1), y(idx(i):idx(i+1)-1)];
end

% Plot figure
fig = figure(Theme='Light');
ax = axes(fig);

set(ax, FontName='Helvetica', FontSize=18, LineWidth=2)
box on

lin = zeros(nDatasets, 1);
for i = 1:nDatasets
    hold on
    lin(i) = plot(dataset{i}(:,1), dataset{i}(:,2));
    set(lin(i), LineWidth=2)
    hold off
end

% ax.Children((end+1)-2).Color = [0.1 0.1 0.1];
% ax.Children((end+1)-2).Color = ax.Children((end+1)-1).Color;
% uistack(ax.Children((end+1)-2), "bottom")

axis tight

xlabel('{\itE} (V vs. SCE)', FontName='Helvetica', FontSize=20)
ylabel('{\itj} (mA cm^{−2})', FontName='Helvetica', FontSize=20)

adjustAspectRatio(fig, 5, 1.2)

% l = legend(ax, ...
%         {'0'; '200'}, ...
%         'Location', 'southeast');
% 
% addLegendTitle(l, '{\itR}_{s} (Ω)', 'top', false)

% Creating folder to save analysis
if saveToAnalysisFolder == true
    % Creating folder to save analysis
    savePath = createAnalysisFolder(dataPath{1}, expName);
    
    % Copy files
    if isfile(dataPath{1})
        copyFile(savePath, dataPath)
    end
elseif saveToAnalysisFolder == false
    savePath = fileparts(dataPath{1});
elseif strcmp(saveToAnalysisFolder, 'parent')
    parentPath = fileparts(fileparts(dataPath{1}));
    savePath = createAnalysisFolder(parentPath, expName);
end

% Saving figures
saveFig(fig, 'output', savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Save workspace
save(append(savePath, filesep, append(expName,'_workspace.mat')))