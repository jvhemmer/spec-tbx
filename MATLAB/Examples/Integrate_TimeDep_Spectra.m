% Integrate_TimeDep_Spectra: Reads n data files, looks for a single peak
% within an interval, calculates the peak frequency and area and saves it
% for each frame.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   For documentation, see: github.com/jvhemmer/data-processing/
%   johann.hemmer@louisville.edu
%   15 Mar 2024
clear
close all
clc

%% Basic Parameters (edit here)
% Experiment name (comment out or leave blank to use file name). If
% multiple files are used, expName is ignored.
expName = '';

% Path to data files (char separated by space, semicolor or new line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\01. EC-SERS\Data\Nile Blue Activation Energy\08092024\2024-08-09 14_37_13 CV8 r-Ag 2.csv"
};

bkgPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\01. EC-SERS\Data\Nile Blue Activation Energy\08092024\2024-08-09 13_30_04 DC.csv"
};

% Experiment parameters
fps = 1; % frames per second (from LightField)

%% Main loop
nFiles = length(dataPath);

% Process background spectrum
if exist('bkgPath', 'var')
    if ~isempty(bkgPath{1})
        [~, bkgIntensity] = readSpectra(bkgPath);

        avgBkgIntensity = avgSpectra(bkgIntensity);
    end
end

% Preallocating
peakPos = cell([1 nFiles]);
peakArea = cell([1 nFiles]);

% Loop each file
for iFile = 1:nFiles
    %% Reading data
    % Convert 'dataPath' to char in case it is string, to avoid problems
    dataPath{iFile} = char(dataPath{iFile}); % using cell for backwards compatibility
    disp(['Reading file ' num2str(iFile) ' of ' num2str(nFiles) '.'])

    % Read the data contained in the file
    [wavelength, intensity] = readSpectra(dataPath{iFile});
    
    % Convert wavelength to Raman shift
    ramanShift = wavelengthToRS(wavelength, 636.49);
    
    % Background subtraction
    corrIntensity = intensity - avgBkgIntensity;

    % Find and integrate the peak in all frames
    [peakPos{iFile}, peakArea{iFile}, QC] = integrateFrameByFrame( ...
        ramanShift, corrIntensity, ...
        'MinimumSNR', 3, ...
        'PolynomialDegree', 2, ...
        'WindowSize', 7, ...
        'PeakRange', [550 675], ...
        'NoiseRange', [800 1000]);

    %% Saving figures
    if isempty(expName)
        savePath = createAnalysisFolder(dataPath{iFile});
    else
        if length(dataPath) <= 1
            savePath = createAnalysisFolder(dataPath{iFile}, expName);
        else
            savePath = createAnalysisFolder(dataPath{iFile});
        end
    end

    saveAllFigs(savePath, 'fig', 'pdf', 'png')
    disp(['Done saving figures at ' savePath '.'])

    % Saving the areas
    saveTable(peakPos{iFile}, peakArea{iFile}, ...
        'SavePath', savePath, ...
        'VariableNames', {'Raman Shift', 'Area'}, ...
        'FileName', 'areas.txt');

    % Saving a report
    saveReport(savePath)
end