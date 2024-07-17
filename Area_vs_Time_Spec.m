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

%% Basic Parameters (edit here)
% Experiment name (comment out or leave blank to use file name). If
% multiple files are used, expName is ignored.
expName = 'A vs t';

% Path to data files (char separated by space, semicolor or new line)
dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\01. EC-SERS\Data\Nile Blue Activation Energy\07122024\2024-07-12 10_50_21 CV8 25C_Analysis\areas.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\01. EC-SERS\Data\Nile Blue Activation Energy\07122024\2024-07-12 11_05_13 DPV4 25C_Analysis\areas.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\01. EC-SERS\Data\Nile Blue Activation Energy\07122024\2024-07-12 11_17_42 CV8 30C_Analysis\areas.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\01. EC-SERS\Data\Nile Blue Activation Energy\07122024\2024-07-12 11_31_08 DPV4 30C_Analysis\areas.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\01. EC-SERS\Data\Nile Blue Activation Energy\07122024\2024-07-12 11_55_58 CV8 36C_Analysis\areas.txt"
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\3. Projects\01. EC-SERS\Data\Nile Blue Activation Energy\07122024\2024-07-12 12_09_27 DPV 36C_Analysis\areas.txt"
};

% Basic figure setup
xLabel = '{\itt} (s)';
yLabel = 'Area';
xLim = [];
yLim = [];
xTicks = [];
yTicks = [];
yExponent = 3;

% Figure style setup
fontName = 'Arial';
fontSize = 20;
numSize = 18;
lineWidth = 2;
color = [0 0.4470 0.7410];
plotWidth = 8; % Length of the plot axes in inches
aspectRatio = 2.4; % Lenght/Height of the plot axes

%% Main loop
nFiles = length(dataPath);

% Loop each file
for iFile = 1:nFiles
    %% Reading data
    % Convert 'dataPath' to char in case it is string, to avoid problems
    dataPath{iFile} = char(dataPath{iFile});
    
    % Display current file name
    [~, fileName, ext] = fileparts(dataPath{iFile});
    file = [fileName ext];
    disp(['Reading file ' num2str(iFile) ' of ' num2str(nFiles) ': ' file '.'])

    % Read the data contained in the file
    data = readmatrix(dataPath{iFile});
    
    % Separate columns into new vectors
    % x = data(:, 1);
    y = data(:, 2);

    fps = 10;
    totalTime = (length(y) - 1)/fps;
    time = 0:(1/fps):totalTime;
    
    %% Plotting
    % Create a figure to show the second derivative
    [fig, ax] = createFigure( ...
        'xLabel', xLabel, ...
        'yLabel', yLabel, ...
        'xLim', [0 totalTime], ...
        'yLim', [0 max(y)], ...
        'visible', 'on', ...
        'yExponent', yExponent, ...
        'plotWidth', plotWidth, ...
        'aspectRatio', aspectRatio);

    createPlot(ax, time, y, ...
        'LineWidth', lineWidth);

    %% Saving figure
    if isempty(expName)
        savePath = createAnalysisFolder(dataPath{iFile});
    else
        if length(dataPath) <= 1
            savePath = createAnalysisFolder(dataPath{iFile}, expName);
        else
            savePath = createAnalysisFolder(dataPath{iFile});
        end
    end

    saveFig(fig, 'output', savePath, ...
        'fig', 'pdf', 'png')

    disp(['Done saving figures at ' savePath '.'])

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

%% Subroutines
function [fig, ax] = createFigure(options)
% createFigure: encapsulates MATLAB's figure objects to make them easier to
% use and already pre-configures the figures and axes with the preferred 
% settings in the Wilson Lab.
% v1.2.0

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
        options.XLim = ''
        options.YLim = ''
        options.hold = 'on'
        options.yExponent = ''
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

    if not(isempty(options.XLim))
        ax.XLim = options.XLim;
    end
    
    if not(isempty(options.YLim))
        ax.YLim = options.YLim;
    end

    if not(isempty(options.yExponent))
        ax.YAxis.Exponent = options.yExponent;
    end

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
