% Data processing for Nile Blue activation energy mapping.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   For documentation, see: github.com/jvhemmer/data-processing/
%   johann.hemmer@louisville.edu
%   1 Oct 2024
clear
close all
clc

%% Basic Parameters
% Experiment name (leave blank to use file name).
expName = 'Mapping 1 uM NB (full potential range)';

% Path to data files (char separated by space, semicolor or new line)
dataPath = { % SERS data
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-07 01_47_31 Mapping 1uM NB 10x10 pos = (-46.0, -43.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-07 01_40_30 Mapping 1uM NB 10x10 pos = (-40.0, -43.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-07 01_33_29 Mapping 1uM NB 10x10 pos = (-35.0, -43.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-07 01_26_28 Mapping 1uM NB 10x10 pos = (-29.0, -43.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-07 01_19_27 Mapping 1uM NB 10x10 pos = (-25.0, -43.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-07 01_12_25 Mapping 1uM NB 10x10 pos = (-20.0, -43.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-07 01_05_24 Mapping 1uM NB 10x10 pos = (-15.0, -43.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-07 00_58_23 Mapping 1uM NB 10x10 pos = (-10.0, -43.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-07 00_51_22 Mapping 1uM NB 10x10 pos = (-4.0, -43.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-07 00_44_20 Mapping 1uM NB 10x10 pos = (-1.0, -43.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-07 00_37_14 Mapping 1uM NB 10x10 pos = (-46.0, -38.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-07 00_30_13 Mapping 1uM NB 10x10 pos = (-40.0, -38.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-07 00_23_11 Mapping 1uM NB 10x10 pos = (-35.0, -38.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-07 00_16_10 Mapping 1uM NB 10x10 pos = (-29.0, -38.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-07 00_09_09 Mapping 1uM NB 10x10 pos = (-25.0, -38.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-07 00_02_08 Mapping 1uM NB 10x10 pos = (-20.0, -38.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 23_55_07 Mapping 1uM NB 10x10 pos = (-15.0, -38.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 23_48_06 Mapping 1uM NB 10x10 pos = (-10.0, -38.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 23_41_02 Mapping 1uM NB 10x10 pos = (-4.0, -38.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 23_34_01 Mapping 1uM NB 10x10 pos = (-1.0, -38.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 23_26_54 Mapping 1uM NB 10x10 pos = (-45.0, -34.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 23_19_53 Mapping 1uM NB 10x10 pos = (-40.0, -34.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 23_12_52 Mapping 1uM NB 10x10 pos = (-35.0, -34.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 23_05_51 Mapping 1uM NB 10x10 pos = (-29.0, -34.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 22_58_50 Mapping 1uM NB 10x10 pos = (-25.0, -34.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 22_51_48 Mapping 1uM NB 10x10 pos = (-20.0, -34.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 22_44_47 Mapping 1uM NB 10x10 pos = (-15.0, -34.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 22_37_46 Mapping 1uM NB 10x10 pos = (-10.0, -34.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 22_30_45 Mapping 1uM NB 10x10 pos = (-4.0, -34.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 22_23_43 Mapping 1uM NB 10x10 pos = (-1.0, -34.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 22_16_37 Mapping 1uM NB 10x10 pos = (-45.0, -28.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 22_09_36 Mapping 1uM NB 10x10 pos = (-40.0, -28.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 22_02_35 Mapping 1uM NB 10x10 pos = (-35.0, -28.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 21_55_33 Mapping 1uM NB 10x10 pos = (-29.0, -28.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 21_48_32 Mapping 1uM NB 10x10 pos = (-25.0, -28.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 21_41_31 Mapping 1uM NB 10x10 pos = (-20.0, -28.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 21_34_30 Mapping 1uM NB 10x10 pos = (-15.0, -28.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 21_27_29 Mapping 1uM NB 10x10 pos = (-10.0, -28.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 21_20_27 Mapping 1uM NB 10x10 pos = (-4.0, -28.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 21_13_26 Mapping 1uM NB 10x10 pos = (0.0, -28.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 21_06_19 Mapping 1uM NB 10x10 pos = (-45.0, -23.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 20_59_18 Mapping 1uM NB 10x10 pos = (-40.0, -23.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 20_52_17 Mapping 1uM NB 10x10 pos = (-35.0, -23.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 20_45_16 Mapping 1uM NB 10x10 pos = (-29.0, -23.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 20_38_15 Mapping 1uM NB 10x10 pos = (-25.0, -23.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 20_31_13 Mapping 1uM NB 10x10 pos = (-20.0, -23.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 20_24_12 Mapping 1uM NB 10x10 pos = (-15.0, -23.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 20_17_11 Mapping 1uM NB 10x10 pos = (-10.0, -23.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 20_10_10 Mapping 1uM NB 10x10 pos = (-4.0, -23.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 20_03_08 Mapping 1uM NB 10x10 pos = (-1.0, -23.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 19_56_02 Mapping 1uM NB 10x10 pos = (-46.0, -18.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 19_49_00 Mapping 1uM NB 10x10 pos = (-40.0, -18.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 19_41_59 Mapping 1uM NB 10x10 pos = (-35.0, -18.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 19_34_58 Mapping 1uM NB 10x10 pos = (-29.0, -18.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 19_27_57 Mapping 1uM NB 10x10 pos = (-25.0, -18.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 19_20_56 Mapping 1uM NB 10x10 pos = (-20.0, -18.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 19_13_54 Mapping 1uM NB 10x10 pos = (-15.0, -18.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 19_06_53 Mapping 1uM NB 10x10 pos = (-10.0, -18.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 18_59_52 Mapping 1uM NB 10x10 pos = (-4.0, -18.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 18_52_51 Mapping 1uM NB 10x10 pos = (-1.0, -18.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 18_45_44 Mapping 1uM NB 10x10 pos = (-46.0, -14.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 18_38_43 Mapping 1uM NB 10x10 pos = (-40.0, -14.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 18_31_42 Mapping 1uM NB 10x10 pos = (-35.0, -14.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 18_24_40 Mapping 1uM NB 10x10 pos = (-29.0, -14.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 18_17_39 Mapping 1uM NB 10x10 pos = (-25.0, -14.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 18_10_38 Mapping 1uM NB 10x10 pos = (-20.0, -14.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 18_03_37 Mapping 1uM NB 10x10 pos = (-15.0, -14.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 17_56_36 Mapping 1uM NB 10x10 pos = (-10.0, -14.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 17_49_34 Mapping 1uM NB 10x10 pos = (-4.0, -14.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 17_42_33 Mapping 1uM NB 10x10 pos = (-1.0, -14.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 17_35_27 Mapping 1uM NB 10x10 pos = (-46.0, -9.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 17_28_25 Mapping 1uM NB 10x10 pos = (-40.0, -9.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 17_21_24 Mapping 1uM NB 10x10 pos = (-35.0, -9.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 17_14_23 Mapping 1uM NB 10x10 pos = (-29.0, -9.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 17_07_22 Mapping 1uM NB 10x10 pos = (-25.0, -9.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 17_00_21 Mapping 1uM NB 10x10 pos = (-20.0, -9.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 16_53_20 Mapping 1uM NB 10x10 pos = (-15.0, -9.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 16_46_18 Mapping 1uM NB 10x10 pos = (-10.0, -9.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 16_39_17 Mapping 1uM NB 10x10 pos = (-4.0, -9.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 16_32_16 Mapping 1uM NB 10x10 pos = (-1.0, -9.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 16_25_09 Mapping 1uM NB 10x10 pos = (-46.0, -4.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 16_18_08 Mapping 1uM NB 10x10 pos = (-40.0, -4.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 16_11_07 Mapping 1uM NB 10x10 pos = (-35.0, -4.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 16_04_06 Mapping 1uM NB 10x10 pos = (-29.0, -4.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 15_57_05 Mapping 1uM NB 10x10 pos = (-25.0, -4.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 15_50_03 Mapping 1uM NB 10x10 pos = (-20.0, -4.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 15_43_02 Mapping 1uM NB 10x10 pos = (-15.0, -4.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 15_36_01 Mapping 1uM NB 10x10 pos = (-10.0, -4.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 15_29_00 Mapping 1uM NB 10x10 pos = (-4.0, -4.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 15_21_58 Mapping 1uM NB 10x10 pos = (-1.0, -4.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 15_14_52 Mapping 1uM NB 10x10 pos = (-46.0, 0.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 15_07_51 Mapping 1uM NB 10x10 pos = (-40.0, 0.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 15_00_49 Mapping 1uM NB 10x10 pos = (-35.0, 0.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 14_53_48 Mapping 1uM NB 10x10 pos = (-29.0, 0.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 14_46_47 Mapping 1uM NB 10x10 pos = (-25.0, 0.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 14_39_46 Mapping 1uM NB 10x10 pos = (-20.0, 0.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 14_32_45 Mapping 1uM NB 10x10 pos = (-15.0, 0.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 14_25_43 Mapping 1uM NB 10x10 pos = (-10.0, 0.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 14_18_42 Mapping 1uM NB 10x10 pos = (-4.0, 0.csv"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\10062024\2024-10-06 14_11_41 Mapping 1uM NB 10x10 pos = (0.0, 0.csv"
};

bkgPath = { % SERS background spectra
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\1. Data\Nile Blue Activation Energy\09292024\2024-09-29 12_07_38 DC.csv"
};

% Experiment parameters
fps = 1; % frames per second (from LightField)
E_range = [0 -0.6]; % V
scanRate = 0.005; % V/s
% peakRange = [568 613];
peakRange = [400 1800];
EhalfExpectedRange = [-0.5 0];

%% Execution
nData = length(dataPath);

% Generate potential waveform
[potential, time] = calculateWaveform(0, -0.6, fps, scanRate, 1);

% Process background spectrum
if not(isempty(bkgPath))
    [~, bkgIntensity] = readSpectra(bkgPath);

    avgBkgIntensity = avgSpectra(bkgIntensity);
end

% Preallocate
area = cell([nData 1]);
smoothArea = cell([nData 1]);
derArea = cell([nData 1]);
smoothDer = cell([nData 1]);
Ehalf = cell([nData 1]);
wavelength = cell([nData 1]);
intensity = cell([nData 1]);
corrIntensity = cell([nData 1]);
QC = cell([nData 1]);

for i = 1:nData
    % Read the data contained in the file
    [wavelength{i}, intensity{i}] = readSpectra(dataPath{i});
    
    if i == 1
        % Convert wavelength to Raman shift
        ramanShift = wavelengthToRS(wavelength{1}, 636.75);
    end
    
    % Background subtraction
    corrIntensity{i} = intensity{i} - avgBkgIntensity;
    
    % Find and integrate the peak in all frames
    area{i} = nan([size(corrIntensity{i}, 2) 1]);
    for frame = 1:size(corrIntensity{i}, 2)
        [area{i}(frame), QC{i}(frame)] = integratePeak(ramanShift, corrIntensity{i}(:,frame), peakRange);
    end

    smoothArea{i} = mirroredSGolayFilt(area{i}, 2, 65);

    derArea{i} = -diff(smoothArea{i})./diff(potential');
    
    smoothDer{i} = mirroredSGolayFilt(derArea{i}, 2, 65);
    
    % Look for the minimum only in the expected range of Ehalf
    potentialEhalfExpectedRange = potential >= EhalfExpectedRange(1) & potential <= EhalfExpectedRange(2);
    potentialEhalfExpectedRange = potential(potentialEhalfExpectedRange);
    
    [~, indices] = ismember(potentialEhalfExpectedRange, potential);
    
    % Ehalf should be when the derivative is minimum
    Ehalf{i} = potentialEhalfExpectedRange(smoothDer{i}(indices)==min(smoothDer{i}(indices)));
end

EhalfArray = cell2mat(Ehalf);

EhalfMatrix = reshape(EhalfArray, [10 10]);

% EhalfMatrix = flipud(EhalfMatrix');

% Creating figure for heatmap
mapfig = figure;
mapfig.Theme = 'light';

map = heatmap(mapfig, EhalfMatrix); % plotting heatmap

% Formatting heatmap
map.FontSize = 18;
map.CellLabelColor = "none";
map.Colormap = jet(64);

map.Units = 'inches';
map.Position(3) = 4;
map.Position(4) = 4;

% Making sure the axes fit inside the figure window
mapfig.Units = 'inches';
mapfig.InnerPosition([3 4]) = map.OuterPosition([3 4])*1.1;

map.XDisplayLabels = 45:-5:0;
map.YDisplayLabels = 45:-5:0;

% Doing the label in Inkscape because MATLAB doesn't support the label and
% the ticks being different font sizes for a heatmap
% map.XLabel = 'x distance from origin (μm)';
% map.YLabel = 'y distance from origin (μm)';

spot = 1;

fig = figure;

% Create axes for the first subplot
ax1 = subplot(1, 2, 1);  % 1 row, 2 columns, 1st subplot
plot(ax1, potential, smoothArea{spot});
xlabel(ax1, 'E');
ylabel(ax1, 'A');

% Create axes for the second subplot
ax2 = subplot(1, 2, 2);  % 1 row, 2 columns, 2nd subplot
plot(ax2, potential(1:end-1), smoothDer{spot});
title(ax2, 'Smooth Derivative');
xlabel(ax2, 'E');
ylabel(ax2, 'dA/dE');
% 
% fig.Position(3) = fig.Position(3) * 2;

%% Saving
savePath = createAnalysisFolder(dataPath{1}, expName);
% 
saveAllFigs(savePath, 'fig', 'pdf', 'png')
disp(['Done saving figures at ' savePath '.'])
% 
% Saving the areas
saveTable(potential', area{i}, ... 
    'SavePath', savePath, ...
    'VariableNames', {'Potential (V)', 'Area'}, ...
    'FileName', 'areas.txt');

% Copy files
copyFile(savePath, dataPath, bkgPath)

% Saving a report
saveReport(savePath)