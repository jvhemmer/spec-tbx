% Area_vs_Time_Spec: creates an Area vs time plot using data obtained by 
% numerical integration of spectrometric data.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   For documentation, see: github.com/jvhemmer/data-processing/
%   johann.hemmer@louisville.edu
%   27 Jun 2024
clear
close all
clc

% Name for folder. Leave blank to use file name automatically.
expName = 'A vs t'; 

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\01. EC-SERS\Data\Nile Blue Activation Energy\08092024\2024-08-09 14_37_13 CV8 r-Ag 2_Analysis\areas.txt"
};

% Loop each file
for iFile = 1:length(dataPath)
    % Convert 'dataPath' to char in case it is string, to avoid problems
    dataPath{iFile} = char(dataPath{iFile});
    
    % Display current file name
    [~, fileName, ext] = fileparts(dataPath{iFile});
    file = [fileName ext];
    disp(['Reading file ' num2str(iFile) ' of ' num2str(nFiles) ': ' file '.'])
    
    % Separate columns into new vectors
    area = readData(dataPath{iFile}, 2);
    area = area{1};

    fps = 1;
    totalTime = (length(area) - 1)/fps;
    time = 0:(1/fps):totalTime;
    
    % Plotting
    [fig, ax] = plotXY(time, area, ...
        'XLabel', '{\itt} (s)', ...
        'YLabel', 'Area', ...
        'YExponent', 3, ...
        'AspectRatio', 2.4, ...
        'PlotWidth', 8);

    % Creating folder to save analysis
    if isempty(expName)
        savePath = createAnalysisFolder(dataPath{iFile});
    else
        if length(dataPath) <= 1
            savePath = createAnalysisFolder(dataPath{iFile}, expName);
        else
            savePath = createAnalysisFolder(dataPath{iFile});
        end
    end
    
    % Saving figures
    saveFig(fig, 'output', savePath, 'fig', 'png', 'pdf')

    % Saving report
    saveReport(savePath)
end