% Avg_and_Integrate_Raman: Reads n data files, looks for a single peak
% within an interval, calculates the peak frequency and area and saves it.
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
% multiple files are used, expName is ignored since there will be many
% output files.
expName = '';

% Path to data files (char separated by space, semicolor or new line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\01. EC-SERS\Data\Aq CO2RR on r-Ag disk\2024\03 Mar\03142024\2024-03-14 17_31_15 step -0.2 300s pos = (-2465.68, 2221.12).csv"
};

% Experiment parameters
peakRange = [2000 2200]; % Range you expect the peak to be in
laserWavelength = 531.689; % Wavelength of the laser
noiseRange = [1800 2050];
minimumSNR = 10;

% Figure style setup
color = [0 0.4470 0.7410];
lineWidth = 2;

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
    
    % Separate columns into new vectors
    wavelength = data(:, 1);
    intensity = data(:, 2);
    frames = data(end, 3);
    xWidth = data(end, 6) + 1;
    
    %% Calculate Raman Shift
    wavenumber = 1./wavelength(1:xWidth, 1);
    laserWavenumber = 1/laserWavelength;
    ramanShift = 1e7 * (laserWavenumber - wavenumber);
    
    %% Calculate sum and average
    % Reshape intensity array into a matrix where each column is a frame
    intensity = reshape(intensity, [xWidth frames]);

    % Sum and average intensities of each frames
    summedIntensity = sum(intensity, 2);
    averagedIntensity = summedIntensity/frames;
    
    %% Finding and integrating the peak
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
    
    % Finding peak limits
    [limits, derData] = findPeakLimits(ramanShiftRange, smoothIntensity);

    startRamanShift = limits(1);
    endRamanShift = limits(2);

    startIdx = find(ramanShiftRange==startRamanShift);
    endIdx = find(ramanShiftRange==endRamanShift);
    
    if peakFound
        % If the peak is outsite the range of the peak start and end found by
        % the second derivative, then probably there's no peak or the data is
        % too noisy.
        if peakRamanShift > endRamanShift || peakRamanShift < startRamanShift
            peakFound = false;
            warning("Peak not found in range.")
        end

    % Integrating
    [peakArea{iFile}, integration] = integratePeak(ramanShiftRange, intensityRange, limits);

    end

    %% Plotting
    % Create figure and axes objects
    % Create a figure to show the second derivative
    [fig1, ax1] = createFigure( ...
        'xLabel', 'Raman shift (cm^{−1})', ...
        'yLabel', 'd^{2}{\itI}/d\nu^{2} (normalized)', ...
        'visible', 'on');

    createPlot(ax1, derData.x, derData.y, ...
        'LineWidth', lineWidth);

    if peakFound
        margin = 0.985;
        xLimits = [startRamanShift*margin endRamanShift*(1 + (1 - margin))];
        set(ax1, 'XTick', round([startRamanShift endRamanShift], 0))
    else
        xLimits = peakRange;
    end

    set(ax1, 'XLim', xLimits)

    % Create a figure to show the identified peak and integration
    [fig2, ax2] = createFigure( ...
        'xLabel', ax1.XLabel.String, ...
        'yLabel', 'Intensity (counts)');

    p = createPlot(ax2, ramanShiftRange, intensityRange, ...
        'LineWidth', lineWidth);

    XLim = ax2.XLim;
    YLim = ax2.YLim;
    ax2.YLimMode = 'manual';
    ax2.XLim = XLim;
    ax2.YLim = YLim;

    if peakFound
        ax2.XTick = round([startRamanShift peakRamanShift  endRamanShift], 0);

    % Plot baseline
    createPlot(ax2, ...
        integration.baselineX, integration.baselineY, ...
        'Color', 'k', ...
        'LineStyle', '--', ...
        'LineWidth', lineWidth);

        % Plot line last so it doesn't rescale the plot
        line(ax2, ...
            round([peakRamanShift peakRamanShift], 0), [0 peakIntensity], ...
            'Color', [0.75 0.75 0.75], ...
            'LineStyle', '--')

        uistack(p, 'top') % Bring main curve to the front

        % Fill area under the curve
        xCoords = [integration.baselineX', fliplr(ramanShiftRange(startIdx:endIdx)')];
        yCoords = [integration.baselineY, fliplr(intensityRange(startIdx:endIdx)')];

        % Use the fill function to create the filled area plot
        filledArea = fill(ax2, xCoords, yCoords, ...
            color, ...
            'FaceAlpha', 0.1, ...
            'EdgeColor', 'none');

        uistack(filledArea, 'bottom'); % Ensure the filled area is behind the plots
    end

    % Plot unfiltered data as comparison
    [fig3, ax3] = createFigure( ...
        'xLabel', ax1.XLabel.String, ...
        'yLabel', ax2.YLabel.String, ...
        'visible', 'on');

    legend(ax3, 'show')

    createPlot(ax3, ramanShiftRange, intensityRange, ...
        'LineStyle', '-', ...
        'DisplayName', 'Original', ...
        'LineWidth', lineWidth);

    createPlot(ax3, ramanShiftRange, smoothIntensity, ...
        'LineStyle', '--', ...
        'Color', 'k', ...
        'DisplayName', 'Smooth', ...
        'LineWidth', lineWidth);

    % Plot noise region
    [fig4, ax4] = createFigure( ...
        'visible', 'on', ...
        'xLabel', ax2.XLabel.String, ...
        'yLabel', ax2.YLabel.String);

    createPlot(ax4, ramanShiftNoiseRange, intensityNoiseRange, ...
        'DisplayName', 'Original', ...
        'LineWidth', lineWidth);

    createPlot(ax4, ramanShiftNoiseRange, noise.fitData, ...
        'Color', 'k', ...
        'LineStyle', '--', ...
        'DisplayName', 'Fit data', ...
        'LineWidth', lineWidth);

    upperBound = intensityNoiseRange + minimumSNR * noise.amplitude;
    lowerBound = intensityNoiseRange;

    fill([ramanShiftNoiseRange; flipud(ramanShiftNoiseRange)], ...
        [lowerBound; flipud(upperBound)], ...
        'r', ...
        'FaceAlpha', 0.2, ...
        'EdgeColor', 'none', ...
        'DisplayName', [num2str(minimumSNR) '{\it\sigma}']);

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

% Remove : from datetime
outputPath = [path{1} filesep strrep(char(datetime), ':', '-') ' allAreas.txt'];

writetable(dataTable, outputPath, 'Delimiter', '\t')

%% Subroutines
function [fig, ax] = createFigure(options)
% createFigure: encapsulates MATLAB's figure objects to make them easier to
% use and already pre-configures the figures and axes with the preferred 
% settings in the Wilson Lab.

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

    fig.UserData = options;

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

% ---

function lin = createPlot(ax, varargin)
    fig = ancestor(ax, 'figure');

    lin = plot(ax, varargin{:});

    % if ~any(isequal(varargin, 'LineWidth'))
    %     line.LineWidth = fig.UserData.lineWidth;
    % end

    % if ~any(isequal(varargin, 'Color'))
    %     line.Color = fig.UserData.color;
    % end

    plotHeight = fig.UserData.plotWidth/fig.UserData.aspectRatio;
    
    ax.OuterPosition([1 2]) = [0 0];
    ax.Position([3 4]) = [fig.UserData.plotWidth plotHeight];
    fig.Position([3 4]) = ax.OuterPosition([3 4]);
end

% ---

function saveFig(fig, name, path, formats)
%saveFig: Saves a figure object to one of multiple output formats.
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
%   savedata(fig, 'spec', 'C:/Data/Spectrum', 'png', 'svg', 'pdf')

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

% ---

function [savePath] = createAnalysisFolder(path, name)
% createAnalysisFolder: functions to facilitate the creation of an Analysis
% folder. If a file path is provided in "path", the function creates a
% folder with the same name in the same path but appends "_Analysis" to the
% folder's name. If it is a folder, the folder is created.

    arguments
        path (1,:) char
        name (1,:) char = ''
    end

    if isfolder(path)
        savePath = path;
    else
        % Get the parts of the file name and path;
        [folderPath, fileName, ext] = fileparts(path);
    
        warning('off', 'MATLAB:MKDIR:DirectoryExists')
    
        if isempty(name)
            name = fileName;
        end

        % Folder to save the analysis files
        savePath = [folderPath filesep name '_Analysis'];
    end
    
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
            {name});
        if ~isempty(sel)
            % If user clicked 'Ok'
            if isempty(sel{1})
                % If provided input is blank
                error('No input provided.')
            elseif isequal(sel{1}, name)
                % If the input is equal to expName, overwrite
                disp('Overwriting...')
                mkdir(savePath)
    
            else
                % If the input is different than expName, create new folder
                disp('Creating new folder...')
                name = sel{1};
                savePath = [folderPath filesep name '_Analysis'];
                mkdir(savePath)
    
            end
        else
            % If user clicks 'Cancel' or closes the dialog box
            error('Aborted by user.')
        end
    end
end

% ---

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

% ---

function [limits, QC] = findPeakLimits(x, y, options)

    arguments
        x (:,1)
        y (:,1)
        options.minProminence (1,1) = 0.25
        options.window = ''
    end
    
    Dy = diff(y) ./ diff(x); % First derivative dy/dx
    
    % Apply SGF to smooth before second derivative. A greater window for
    % filtering of the second derivative usually results in more
    % accurate peak intervals. However, if the window is too large,
    % artifacts may be introduced.
    if isempty(options.window)
        options.window = round(length(y)/3, 0);
        if mod(options.window, 2) == 0
            options.window = options.window + 1; % must be odd
        end
    end

    smoothDy = sgolayfilt(Dy, 2, options.window);
    
    % Perform second derivative on smoothed first derivative
    D2y = diff(smoothDy) ./ diff(x(1:end-1));
    
    % Normalize the second derivative so the peaks can be filtered by
    % prominence (otherwise MATLAB finds too many peaks)
    normD2y = normalize(D2y, 'range', [-1 1]);
    
    % Find peaks in the second derivative graph. There should be two peaks 
    % corresponding to the start and end of the original peak, respectively,
    % and one valley corresponding to the maximum of the original peak (which
    % is not obtained from here.
    [peaks, locs] = findpeaks(normD2y, x(1:end-2), ...
        'MinPeakProminence', options.minProminence);
    
    % If no second derivative peaks were found, there's probably no peaks
    if isempty(peaks)
        warning("Peak limits couldn't be found.")
    else
        % Find the x-value of the tallest and second tallest peaks
        tallest = locs(peaks==max(peaks));
        secondTallest = locs(peaks==max(peaks(peaks<max(peaks))));
        
        % Peak start is the one with lowest x-value, and vice versa
        peakStart = min(tallest, secondTallest);
        peakEnd = max(tallest, secondTallest);

        % Get peak limits
        limits = [peakStart peakEnd];
    end

    % Export data for QC
    QC.x = x(1:end-2); % X-values for 2 derivative
    QC.y = normD2y; % Normalized second derivative values
end

% ---

function [area, QC] = integratePeak(x, y, limits)

    startX = limits(1);
    endX = limits(2);

    startIdx = find(x == startX);
    endIdx = find(x == endX);

    % Get the indices of the baseline
    baselineIdx = x >= startX & x <= endX;
    
    % Get the Raman shift values of the baseline
    baselineX = x(baselineIdx);
    
    % Create a baseline of intensity values based of the number of elements
    % in the baseline
    baselineLength = length(baselineX);
    baselineY = linspace(y(startIdx), y(endIdx), baselineLength);
    
    % Integrate numerically to get the total area under the curve
    totalPeakArea = trapz(y(startIdx:endIdx));
    
    % Get the area under the baseline
    baselineArea = trapz(baselineY);
    
    % Subtract to get only the area of the peak
    area = totalPeakArea - baselineArea;

    % Save QC data
    QC.limits = limits;
    QC.baselineX = baselineX;
    QC.baselineY = baselineY;
    QC.totalArea = totalPeakArea;
    QC.baselineArea = baselineArea;
end