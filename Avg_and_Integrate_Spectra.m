% Avg_and_Integrate_Raman: Reads n data files, looks for a single peak
% within an interval, calculates the peak frequency and area and saves it.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   15 Mar 2024
clear
close all
clc

%% Basic Parameters (edit here)
% Experiment name (comment out or leave blank to use file name). If
% multiple files are used, expName is ignored since there will be many
% output files.
expName = 'test';

% Path to data files (separated by space, semicolor or new line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\01. EC-SERS\Data\Aq CO2RR on r-Ag disk\2024\03 Mar\03142024\2024-03-14 17_31_15 step -0.2 300s pos = (-2465.68, 2221.12).csv"
};

% Experiment parameters
peakRange = [2000 2200]; % Range you expect the peak to be in
laserWavelength = 531.884; % Wavelength of the laser
noiseRange = [1800 2050];
minimumSNR = 10;

% Figure style setup
fontName = 'Arial';
fontSize = 20;
numSize = 18;
lineWidth = 2;
color = [0 0.4470 0.7410];
plotWidth = 5; % Length of the plot axes in inches
aspectRatio = 1.2; % Lenght/Height of the plot axes

%% Main loop
nFiles = length(dataPath);

% Preallocating
peakPos = cell([1 nFiles]);
peakArea = cell([1 nFiles]);

for iFile = 1:nFiles
    %% Reading data
    % Convert 'dataPath' to char in case it is string, to avoid problems
    dataPath{iFile} = char(dataPath{iFile}); % using cell for backwards compatibility
    
    % Display current file name
    [~, fileName, ext] = fileparts(dataPath{iFile});
    file = [fileName ext];
    disp(['Reading file ' num2str(iFile) ' of ' num2str(nFiles) ': ' file '.'])

    % Read the data contained in the file
    data = readmatrix(dataPath{iFile});
    
    % Read the wavelength data (all rows of the 1st column)
    wavelength = data(:, 1);
    
    % Read the current data (all rows of the 2nd column)
    intensity = data(:, 2);
    
    % Read the total number of frames (check column number from exported data)
    frames = data(end, 3);
    
    % Read the xwidth (check column number from exported data)
    xWidth = data(end, 6) + 1;
    
    %% Calculate Raman Shift
    wavenumber = 1./wavelength(1:xWidth, 1);
    laserWavenumber = 1/laserWavelength;
    
    ramanShift = 1e7 * (laserWavenumber - wavenumber);
    
    %% Reshaping spectra
    % Reshape intensity array into a matrix where each column is a frame
    intensity = reshape(intensity, [xWidth frames]);
    
    %% Calculate sum and average
    % Sum the intensities of each frames
    summedIntensity = sum(intensity, 2);
    
    % Average
    averagedIntensity = summedIntensity/frames;
    
    %% Finding peak
    % Flip the arrays so the ramanShift is in an increasing order
    averagedIntensity = flip(averagedIntensity);
    ramanShift = flip(ramanShift);

    % Get indices withing the specified Raman Shift range
    idxRange = ramanShift >= peakRange(1) & ramanShift <= peakRange(2);
    
    % Get only the range of values we care about
    intensityRange = averagedIntensity(idxRange);
    ramanShiftRange = ramanShift(idxRange);
    
    % Smoothing using Savitzky-Golay Filter
    polynomialDegree = 2;
    windowSize = 17;
    
    % Adjust windowSize if data length is lower than it
    while length(intensityRange) < windowSize
        windowSize = windowSize - 2;
    end

    smoothIntensity = sgolayfilt(intensityRange, polynomialDegree, windowSize);

    % Noise
    noiseIdxRange = ramanShift >= noiseRange(1) & ramanShift <= noiseRange(2);
    ramanShiftNoiseRange = ramanShift(noiseIdxRange);
    intensityNoiseRange = averagedIntensity(noiseIdxRange);

    noise = calculateNoiseAmplitude(intensityNoiseRange);

    % Find the peak within the range
    [pks, locs, ~, prom] = findpeaks(smoothIntensity, ramanShiftRange, ...
        'MinPeakProminence', noise.amplitude * minimumSNR);
    
    % The peak position is the Raman Shift value where MATLAB found the peak
    % with the highest prominence
    peakRamanShift = locs(prom == max(prom));
    peakPos{iFile} = peakRamanShift;

    if isempty(peakRamanShift)
        peakFound = false;
        warning("No peaks above minimum signal-to-noise ratio in the" + ...
            "selected region.")
    else
        peakFound = true;
    end
    
    % Intensity (maximum) of the peak
    peakIntensity = pks(prom == max(prom));
    
    %% Finding peak limits
    % Apply Savitzy-Golay Filter (SGF) to smooth the data before performing the
    % first derivative to reduce noise
    % Perform first derivative
    firstDerivative = diff(smoothIntensity) ./ diff(ramanShiftRange);
    
    % Apply SGF to smooth before second derivative. A greater window for
    % filtering of the second derivative usually results in more
    % accurate peak intervals. However, if the window is too large,
    % artifacts may be introduced.
    derWindow = round(length(intensityRange)/3, 0);
    if mod(derWindow, 2) == 0
        derWindow = derWindow + 1; % must be odd
    end
    smoothDerivative = sgolayfilt(firstDerivative, 2, derWindow);
    
    % Perform second derivative on smoothed first derivative
    secondDerivative = diff(smoothDerivative) ./ diff(ramanShiftRange(1:end-1));
    
    % Normalize the second derivative so the peaks can be filtered by
    % prominence (otherwise MATLAB finds too many peaks
    normSecondDer = normalize(secondDerivative, 'range', [-1 1]);
    
    % Find peaks in the second derivative graph. There should be two peaks 
    % corresponding to the start and end of the original peak, respectively,
    % and one valley corresponding to the maximum of the original peak (which
    % is not obtained from here.
    [derPeaks, derLocs] = findpeaks(normSecondDer, ramanShiftRange(1:end-2), ...
        'MinPeakProminence', 0.25);
    
    % If no second derivative peaks were found, there's probably no peaks
    if peakFound
        if isempty(derPeaks)
            peakFound = false;
    
            warning("Peak start and end couldn't be found by the second " + ...
                "derivative. There's probably no peak in this region " + ...
                "or something else went wrong.")
        end
    end

    % Find the Raman shift of the tallest and second tallest peaks
    highest = derLocs(derPeaks==max(derPeaks));
    secondHighest = derLocs(derPeaks==max(derPeaks(derPeaks<max(derPeaks))));
    
    % Peak start is the one with lowest Raman shift value, and vice versa
    startRamanShift = min(highest, secondHighest);
    endRamanShift = max(highest, secondHighest);
    
    % Get corresponding indices
    startIdx = find(ramanShiftRange == startRamanShift);
    endIdx = find(ramanShiftRange == endRamanShift);
    
    % If the peak is outsite the range of the peak start and end found by
    % the second derivative, then probably there's no peak or the data is
    % too noisy.
    if peakFound
        if peakRamanShift > endRamanShift || peakRamanShift < startRamanShift
            peakFound = false;
            warning(["Peak is outside the range calculated by the second " ...
                "derivative. There's probably no peak in this region " + ...
                "or something else went wrong."])
        end
    end

    %% Integrating
    % Get the indices of the baseline
    baselineIdx = ramanShiftRange >= startRamanShift & ramanShiftRange <= endRamanShift;
    
    % Get the Raman shift values of the baseline
    baselineRamanShift = ramanShiftRange(baselineIdx);
    
    % Create a baseline of intensity values based of the number of elements
    % in the baseline
    baselineLength = length(baselineRamanShift);
    baselineIntensity = linspace(intensityRange(startIdx), intensityRange(endIdx), baselineLength);
    
    % Integrate numerically to get the total area under the curve
    totalPeakArea = trapz(intensityRange(startIdx:endIdx));
    
    % Get the area under the baseline
    baselineArea = trapz(baselineIntensity);
    
    % Subtract to get only the area of the peak
    peakArea{iFile} = totalPeakArea - baselineArea;
    
    %% Plotting
    % Create figure and axes objects
    % Create a figure to show the second derivative
    [fig1, ax1] = createFigure( ...
        'xLabel', 'Raman shift (cm^{−1})', ...
        'yLabel', 'd^{2}{\itI}/d\nu^{2} (normalized)', ...
        'visible', 'off');
    
    plot(ax1, ramanShiftRange(1:end-2), normSecondDer, ...
        'LineWidth', lineWidth)
    
    if peakFound
        margin = 0.985;
        xLimits = [startRamanShift*margin endRamanShift*(1 + (1 - margin))];
    else
        xLimits = peakRange;
    end

    set(ax1, ...
        'XTick', round([startRamanShift endRamanShift], 0), ...
        'XLim', xLimits)
    
    % Create a figure to show the identified peak and integration
    [fig2, ax2] = createFigure( ...
        'xLabel', ax1.XLabel.String, ...
        'yLabel', 'Intensity (counts)');

    p = plot(ax2, ...
        ramanShiftRange, intensityRange, ...
        'Color', color, ...
        'LineWidth', lineWidth);

    XLim = ax2.XLim;
    YLim = ax2.YLim;
    ax2.YLimMode = 'manual';
    ax2.XLim = XLim;
    ax2.YLim = YLim;

    if peakFound
        ax2.XTick = round([startRamanShift peakRamanShift  endRamanShift], 0);

    % Plot baseline
    plot(ax2, ...
        baselineRamanShift, baselineIntensity, ...
        'Color', 'k', ...
        'LineStyle', '--', ...
        'LineWidth', lineWidth)

        % Plot line last so it doesn't rescale the plot
        line(ax2, ...
            round([peakRamanShift peakRamanShift], 0), [0 peakIntensity], ...
            'Color', [0.75 0.75 0.75], ...
            'LineStyle', '--', ...
            'LineWidth', lineWidth)
    
        uistack(p, 'top') % Bring main curve to the front
        
        % Fill area under the curve
        xCoords = [baselineRamanShift', fliplr(ramanShiftRange(startIdx:endIdx)')];
        yCoords = [baselineIntensity, fliplr(intensityRange(startIdx:endIdx)')];
    
        % Use the fill function to create the filled area plot
        filledArea = fill(xCoords, yCoords, ...
            color, ...
            'FaceAlpha', 0.1, ...
            'EdgeColor', 'none');
    
        uistack(filledArea, 'bottom'); % Ensure the filled area is behind the plots
    end

    % Plot unfiltered data as comparison
    [fig3, ax3] = createFigure( ...
        'xLabel', ax1.XLabel.String, ...
        'yLabel', ax2.YLabel.String, ...
        'visible', 'off');

    legend(ax3, 'show')

    plot(ax3, ramanShiftRange, intensityRange, ...
        'LineStyle', '-', ...
        'LineWidth', lineWidth, ...
        'DisplayName', 'Original')

    plot(ax3, ramanShiftRange, smoothIntensity, ...
        'LineStyle', '--', ...
        'Color', 'k', ...
        'LineWidth', lineWidth, ...
        'DisplayName', 'Smooth')
    
    % Plot noise region
    [fig4, ax4] = createFigure( ...
        'visible', 'off', ...
        'xLabel', ax2.XLabel.String, ...
        'yLabel', ax2.YLabel.String);

    plot(ax4, ramanShiftNoiseRange, intensityNoiseRange, ...
        'LineWidth', lineWidth, ...
        'DisplayName', 'Original')

    plot(ax4, ramanShiftNoiseRange, noise.fitData, ...
        'Color', 'k', ...
        'LineStyle', '--', ...
        'LineWidth', lineWidth, ...
        'DisplayName', 'Fit data')

    upperBound = intensityNoiseRange + minimumSNR * noise.amplitude;
    lowerBound = intensityNoiseRange;

    fill([ramanShiftNoiseRange; flipud(ramanShiftNoiseRange)], ...
        [lowerBound; flipud(upperBound)], ...
        'r', ...
        'FaceAlpha', 0.2, ...
        'EdgeColor', 'none', ...
        'DisplayName', '10{\it\sigma}');

    legend(ax4, 'show')

    %% Saving figures
    savePath = createAnalysisFolder(dataPath{iFile});

    saveFig(fig1, 'second_der', savePath, ...
        'fig', 'pdf', 'png')

    saveFig(fig2, 'integration', savePath, ...
        'fig', 'pdf', 'png')

    saveFig(fig3, 'smooth_comparison', savePath, ...
        'fig', 'pdf', 'png')

    saveFig(fig4, 'noise', savePath, ...
        'fig', 'pdf', 'png')

    disp(['Done saving figures at ' savePath '.'])

    %% Saving the areas
    outputPath = [savePath filesep 'areas.txt'];

    if ~peakFound
        peakPos{iFile} = NaN;
        peakArea{iFile} = NaN;
    end

    writelines('\\ OUTPUT', outputPath, WriteMode='overwrite');
    writelines(['Area of peak at ' num2str(peakPos{iFile}) ' cmˉ¹ = ' num2str(peakArea{iFile})], outputPath, WriteMode='append')

    %% Saving a copy of this script
    callstack = dbstack();
    mainScript = callstack(end).file;

    % Save a copy of this script at the 'savePath' folder
    copyPath = [savePath filesep mainScript];

    copyfile(mainScript, copyPath)

    %% Saving a report
    % Get required dependencies to run the code
    [fList, pList] = matlab.codetools.requiredFilesAndProducts(mainScript);

    apps = struct2table(pList);
    dependencies = fList';

    reportPath = [savePath filesep 'report.txt'];

    % Write preamble
    writelines('\\ ANALYSIS REPORT', reportPath, WriteMode='overwrite');
    writelines(['User: ' getenv('username')], reportPath, WriteMode='append');
    writelines(['OS: ' getenv('os')], reportPath, WriteMode='append');
    writelines(['Date: ' char(datetime)], reportPath, WriteMode='append');
    writelines('', reportPath, WriteMode='append');

    % Write apps used to the report
    writelines('\\ Apps used', reportPath, WriteMode='append');

    writetable(apps, ...
        reportPath, ...
        'Delimiter', '\t', ...
        'WriteVariableNames', true, ...
        'WriteMode','Append');

    writelines('', reportPath, WriteMode='append');

    % Write dependencies used to the report
    writelines('\\ Scripts/routines used', reportPath, WriteMode='append');

    [nrows, ~] = size(dependencies);

    for row = 1:nrows
        writelines(dependencies{row,:}, reportPath, WriteMode='append');
    end

    % Write data files used to the report
    writelines('', reportPath, WriteMode='append');
    writelines('\\ Data files used', reportPath, WriteMode='append');

    writelines([path file], reportPath, WriteMode='append');
end

%% Save all areas in a single file
path = cell([1 nFiles]);
name = cell([1 nFiles]);
for iFile = 1:nFiles
    [path{iFile}, name{iFile}, ~] = fileparts(dataPath{iFile});
end

dataTable = table(name', peakPos', peakArea', 'VariableNames', {'Experiment', 'Raman Shift', 'Area'});

outputPath = [path{1} filesep char(datetime) ' allAreas.txt'];

writetable(dataTable, outputPath, 'Delimiter', '\t')

%% Subroutines
function [fig, ax] = createFigure(options)

    arguments
        options.fontName = 'Arial'
        options.fontSize = 20
        options.numSize = 18
        options.lineWidth = 2
        options.color = [0 0.4470 0.7410]
        options.plotWidth = 5
        options.aspectRatio = 1.2
        options.visible = 'on'
        options.xLabel = ''
        options.yLabel = ''
        options.hold = 'on'
    end

    fig = figure('Visible', options.visible);
    ax = axes(fig);

    xlabel(ax, options.xLabel, ...
        'FontSize', options.fontSize, ...
        'FontName', options.fontName)

    ylabel(ax, options.yLabel, ...
        'FontSize', options.fontSize, ...
        'FontName', options.fontName)

    set(ax, ...
        'LineWidth', options.lineWidth, ...
        'FontName', options.fontName, ...
        'FontSize', options.numSize, ...
        'Box', 'on', ...
        'Layer', 'top', ...
        'Units', 'inches', ...
        'PositionConstraint', 'OuterPosition')

    set(fig, ...
        'Theme', 'light', ...
        'Units', 'inches')

    options.plotHeight = options.plotWidth/options.aspectRatio;
    
    ax.OuterPosition([1 2]) = [0 0];
    ax.Position([3 4]) = [options.plotWidth options.plotHeight];
    fig.Position([3 4]) = ax.OuterPosition([3 4]);

    hold(ax, options.hold)
end

function saveFig(fig, name, path, formats)
%saveFig  Saves a figure object to one of multiple output formats.
%
%   Arguments:
%       fig: MATLAB figure object that will be exported
%       name: name of the output file (excluding extension)
%       path: folder where the file is to be saved at
%       formats: formats that the figure will be saved at (multiple can
%           be specified simultaneously).   
%           Supported formats: fig, png, pdf, svg
%
%   Example:
%   savedata(fig)
%   savedata(fig, 'spectrum', )
%   savedata(fig, 'savename', '01252022 Raman in silver...')
%   savedata(fig, metadata, 'savename', '03132024 CV 100 mVps ...')

    arguments
        fig (1,1) 
        name (1,:) char
        path (1,:) char
    end

    arguments (Repeating)
        formats (1,:) char
    end

    savePath = [path filesep name];

    % Yes, believe it or not, this is a thing
    if length(savePath) > 240
        warning("Save path is near the maximum allowed by Windows. " + ...
            "Some files might not be saved.")
    end

    for iFormat = 1:length(formats)
        switch formats{iFormat}
            case 'fig'
                % MATLAB's native figure format
                savefig(fig, [savePath '.fig'])
            case 'png'
                % Portable Network Graphics (raster)
                % ACS suggests a minimum resolution of 300 for color figures
                exportgraphics(fig, [savePath '.png'], ...
                    'ContentType', 'image', ...
                    'Resolution', 300)
            case 'pdf'
                % Portable Document Format (vector)
                exportgraphics(fig, [savePath '.pdf'], ...
                    'ContentType', 'vector')
            % SVG is not working anymore
            case 'svg'
                % Scalable Vector Graphics (vector)
                saveas(fig, [savePath '.svg'], ...
                    'svg')
        end
    end
end

function [savePath] = createAnalysisFolder(filePath, expName)

    arguments
        filePath (1,:) char
        expName (1,:) char = ''
    end

    % Get the parts of the file name and path;
    [path, fileName, ext] = fileparts(filePath);
    
    warning('off', 'MATLAB:MKDIR:DirectoryExists')

    if isempty(expName)
        expName = fileName;
    end

    % Folder to save the analysis files
    savePath = [path filesep expName '_Analysis'];
    
    if ~exist(savePath, 'dir')
        % If 'savePath' does not exist, create it
        mkdir(savePath);
    else
        % If 'savePath' already exists, ask is user wants to overwrite
        sel = inputdlg( ...
            ['Directory ' savePath ' already exists. Input a new ' ...
            'experiment name or leave same to overwrite. Alternatively, ' ...
            'select Cancel to abort.'], ...
            'Directory already exists.', ...
            1, ...
            {expName});
        if ~isempty(sel)
            % If user clicked 'Ok'
            if isempty(sel{1})
                % If provided input is blank
                error('No input provided.')
            elseif isequal(sel{1}, expName)
                % If the input is equal to expName, overwrite
                disp('Overwriting...')
                mkdir(savePath)
    
            else
                % If the input is different than expName, create new folder
                disp('Creating new folder...')
                expName = sel{1};
                savePath = [path filesep expName '_Analysis'];
                mkdir(savePath)
    
            end
        else
            % If user clicks 'Cancel' or closes the dialog box
            error('Aborted by user.')
        end
    end
end

function correctedData = baselineCorrection(data)
    % Perform asymmetric least squares baseline correction
    lambda = 1e2; % Smoothing parameter, adjust as needed
    p = 0.01;     % Asymmetry parameter, adjust as needed

    % Number of data points
    n = length(data);

    % Identity matrix
    D = diff(speye(n), 2);

    % Penalty matrix
    H = lambda * D' * D;

    % Weights initialization
    w = ones(n, 1);

    % Iteratively reweighted least squares
    for i = 1:10
        W = spdiags(w, 0, n, n);
        Z = W + H;
        z = Z \ (w .* data);
        w = p * (data > z) + (1 - p) * (data < z);
    end

    correctedData = data - z;
end

function out = calculateNoiseAmplitude(data)
    % Fit a polynomial to the data
    x = (1:length(data))';
    out.coefficients = polyfit(x, data, 3);
    
    % Evaluate the fit at the data points
    out.fitData = polyval(out.coefficients, x);
    
    % Calculate the residuals
    out.residuals = data - out.fitData;
    
    % Calculate the standard deviation of the residuals (noise amplitude)
    out.amplitude = std(out.residuals);
end

