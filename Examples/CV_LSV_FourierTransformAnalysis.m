% CV_LSV_FourierTransformAnalysis: Plot CVs and their FTs from data files.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   26 Feb 2025
clear
close all
clc

%% Basic Parameters
% Experiment name (comment out or leave blank to use file name)
expName = '$ FT';

% Path to data files (one per line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Submission 2 (ACS)\LSV\Isothermal trial 5\LSV27 5 mVs.txt"
};

scanRate = 0.005; % V/s
cycles = 1;

electrodeDiameter = 2; % mm
% YScaleFactor = 1e6 / ( pi * ( electrodeDiameter / 10 )^2 / 4 );
YScaleFactor = 1e6;

cycle = [1]; % cicles to plot

nFiles = length(dataPath);

pH = 13.7;
ERHE = @(E) 0.222 + pH*0.059 + E;

% Reading data
potential = cell([nFiles 1]);
current = cell([nFiles 1]);
filtcurrent = cell([nFiles 1]);
FTcurrent = cell([nFiles 1]);
filtFTcurrent = cell([nFiles 1]);

for i = 1:nFiles
    [potential{i}, current{i}] = readData(dataPath{i}, 1, 2);

    % potential{i} = ERHE(potential{i});

    if not(isempty(cycle))
        ptemp = splitArray(potential{i}, cycles);
        ctemp = splitArray(current{i}, cycles);
        potential{i} = ptemp{cycle(i)};
        current{i} = ctemp{cycle(i)};
    end

    % Calculate FT of unadulterated data
    time = timeFromCV(potential{1}, scanRate);

    % current{i} = filterCV(time, current{i}, [0.0980 0.1597]);

    frequencyStep = 1/(time(2) - time(1));

    FTcurrent{i} = abs(fft(detrend(current{i})));

    freqs = (0:length(FTcurrent{i}) - 1) * frequencyStep / length(FTcurrent{i});

    FTcurrent{i} = FTcurrent{i}/length(freqs);

    freqLimit = freqs(end)/2;

    % Apply FT filter(s)
    d = designfilt('bandstopiir', 'FilterOrder', 2, 'HalfPowerFrequency1',0.0047, 'HalfPowerFrequency2',2.5,'SampleRate', frequencyStep);
    filtcurrent{i} = filtfilt(d, current{i});

    % d2 = designfilt('bandstopiir', 'FilterOrder', 2, 'HalfPowerFrequency1',0.5, 'HalfPowerFrequency2',0.7,'SampleRate', frequencyStep);
    % filtcurrent{i} = filtfilt(d2, filtcurrent{i});

    filtFTcurrent{i} = abs(fft(detrend(filtcurrent{i})));

    filtfreqs = (0:length(filtFTcurrent{i}) - 1) * frequencyStep / length(filtFTcurrent{i});

    filtFTcurrent{i} = filtFTcurrent{i}/length(filtfreqs);
end

[fig2, ax2] = plotXY(freqs, {FTcurrent{1}; filtFTcurrent{1}}, ...
    'XLabel', 'ƒ (Hz)', ...
    'YLabel', '{\itF}(ƒ) (μA s)', ...
    'XLim', [freqLimit/100 freqLimit], ...
    'YLim', [], ...
    'LineStyle', {'-'; ':'}, ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'YScaleFactor', 1, ...
    'FigureName', 'FourierTransform');

[fig, ax] = plotXY(potential, {current{1}; filtcurrent{1}}, ...
    'XLabel', '{\itE} (V vs. Ag/AgCl)', ...
    'YLabel', '{\iti} (μA)', ...
    'XLim', [], ...
    'YLim', [], ...
    'LineStyle', {'-'; ':'}, ...
    'AspectRatio', 1.2, ...
    'PlotWidth', 5, ...
    'YScaleFactor', YScaleFactor, ...
    'FigureName', 'current_response');



legend(ax, ...
    {'Original'; 'Filtered'}, ...
    'Location', 'best')

% legend(ax2, ...
%     {'Original'; 'Filtered'}, ...
%     'Location', 'best')

% % Creating folder to save analysis
% savePath = createAnalysisFolder(dataPath{1}, expName);
% 
% % Saving figures
% saveAllFigs(savePath, 'fig', 'png', 'pdf')
% 
% % Saving report
% saveReport(savePath)
% 
% % Copy files
% copyFile(savePath, dataPath)

% FINE TUNE: UNCOMMENT TO USE
hpF1    = 0.0047;    % initial HalfPowerFrequency1 (Hz)
hpF2    = 2.5;       % initial HalfPowerFrequency2 (Hz)
f1Step  = 0.0001;    % step size for left/right
f2Step  = 0.0001;       % step size for up/down
rawC   = current{1};
rawFT  = FTcurrent{1};
t0     = potential{1};

% initial filtered data
d0      = designfilt('bandstopiir', ...
           'FilterOrder',2, ...
           'HalfPowerFrequency1',hpF1, ...
           'HalfPowerFrequency2',hpF2, ...
           'SampleRate',frequencyStep);
filtC0 = filtfilt(d0, rawC);
filtFT0 = abs(fft(detrend(filtC0)));
filtFT0 = filtFT0/length(filtFT0);

% make the figure
hFig = figure('Name','Interactive FT Filter','KeyPressFcn',@onKey);
ax1 = subplot(2,1,1); 
plot(t0, rawC*YScaleFactor,'-');  hold on
hC = plot(t0, filtC0*YScaleFactor,':'); 
hold off
xlabel('{ E } (V vs. Ag/AgCl)'), ylabel('i (μA)')
legend('raw','filtered','Location','best')
title(ax1,sprintf('HPF1=%.4f Hz   HPF2=%.2f Hz',hpF1,hpF2))

ax2 = subplot(2,1,2);
plot(freqs, rawFT,'-');   hold on
hFT = plot(freqs, filtFT0,':'); 
hold off
xlabel('f (Hz)'), ylabel('F(f)')
xlim([freqs(end)/length(freqs) freqs(end)/2])
title(ax2,sprintf('HPF1=%.4f Hz   HPF2=%.2f Hz',hpF1,hpF2))

% stash data & handles in the figure
setappdata(hFig,'rawC',rawC)
setappdata(hFig,'rawFT',rawFT)
setappdata(hFig,'t0',t0)
setappdata(hFig,'freqs',freqs)
setappdata(hFig,'frequencyStep',frequencyStep)
setappdata(hFig,'YScaleFactor',YScaleFactor)
setappdata(hFig,'hpF1',hpF1)
setappdata(hFig,'hpF2',hpF2)
setappdata(hFig,'f1Step',f1Step)
setappdata(hFig,'f2Step',f2Step)
setappdata(hFig,'hC',hC)
setappdata(hFig,'hFT',hFT)
setappdata(hFig,'ax1',ax1)
setappdata(hFig,'ax2',ax2)

% local callback
function onKey(src,evt)
    % pull in stored data
    hpF1   = getappdata(src,'hpF1');
    hpF2   = getappdata(src,'hpF2');
    f1Step = getappdata(src,'f1Step');
    f2Step = getappdata(src,'f2Step');
    rawC   = getappdata(src,'rawC');
    rawFT  = getappdata(src,'rawFT');
    t0     = getappdata(src,'t0');
    freqs  = getappdata(src,'freqs');
    fs     = getappdata(src,'frequencyStep');
    YSF    = getappdata(src,'YScaleFactor');
    hC     = getappdata(src,'hC');
    hFT    = getappdata(src,'hFT');
    ax1    = getappdata(src,'ax1');
    ax2    = getappdata(src,'ax2');

    % figure out multiplier: ctrl=100×, shift=10×, both=1000×
    mods = evt.Modifier;
    if ismember('control',mods) && ismember('shift',mods)
        mult = 1000;
    elseif ismember('control',mods)
        mult = 100;
    elseif ismember('shift',mods)
        mult = 10;
    else
        mult = 1;
    end

    % adjust cutoff frequencies
    switch evt.Key
      case 'leftarrow'
        hpF1 = max(hpF1 - f1Step*mult, 0);
      case 'rightarrow'
        hpF1 = hpF1 + f1Step*mult;
      case 'downarrow'
        hpF2 = max(hpF2 - f2Step*mult, 0);
      case 'uparrow'
        hpF2 = hpF2 + f2Step*mult;
      otherwise
        return
    end

    % save back
    setappdata(src,'hpF1',hpF1)
    setappdata(src,'hpF2',hpF2)

    % redesign filter & refilter
    d    = designfilt('bandstopiir', ...
             'FilterOrder',2, ...
             'HalfPowerFrequency1',hpF1, ...
             'HalfPowerFrequency2',hpF2, ...
             'SampleRate',fs);
    newC = filtfilt(d, rawC);
    newFT = abs(fft(detrend(newC)));
    newFT = newFT/length(newFT);

    % update plots
    set(hC,  'YData', newC*YSF)
    set(hFT, 'YData', newFT)

    % update titles
    title(ax1, sprintf('HPF1=%.4f Hz   HPF2=%.4f Hz', hpF1, hpF2))
    title(ax2, sprintf('HPF1=%.4f Hz   HPF2=%.4f Hz', hpF1, hpF2))

    drawnow
end
