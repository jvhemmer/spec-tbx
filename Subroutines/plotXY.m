function [fig, ax, lin] = plotXY(x, y, options)
% plotXY: Plot a simple X-Y graph.
%
%   Provide arrays for x and y with the same length. It is also possible to
%   input x and y as cell arrays containing multiple numerical arrays. In
%   that case, the lines will be overlaid. If multiple y arrays are
%   provided but only one for x, it will be assumed that all y arrays share
%   the same x axis.
%
%
%   Created by Johann Hemmer
%   johann.hemmer@louisville.edu
%   github.com/jvhemmer/spec-tbx
%   17 Aug 2024
%
%   Arguments:
%       x: x-axis data
%       y: y-axis data
%
%   Optional arguments:
%       Most of the optional arguments work exactly as they do for the 
%       built-in MATLAB graphing functions (e.g., plot, line, bar, mesh, 
%       etc.) and thus the original documentation applies here. New 
%       optional arguments are explained whenever they are used in the 
%       code.

arguments
    x
    y
    options.FontName = 'Arial'
    options.FontSize = 20
    options.NumSize = 18
    options.LineWidth = 2
    options.LineStyle = '-'
    options.Color = [0 0.4470 0.7410]
    options.PlotWidth = []
    options.AspectRatio = []
    options.Visible = 'on'
    options.XLabel = ''
    options.YLabel = ''
    options.XLim = []
    options.YLim = []
    options.XTick = []
    options.YTick = []
    options.YExponent = []
    options.YScaleFactor = 1
    options.Axes = []
    options.Interpreter = 'tex'
    options.LegendLabels = []
    options.LegendLocation = 'best'
    options.FigureName = ''
    options.Units = 'inches'
    options.Theme = 'light'
    options.YAxisLocation = []
    options.Marker = 'none'
    options.MarkerSize = 6
    options.MarkerEdgeColor = [0 0.4470 0.7410]
    options.MarkerFaceColor = [1 1 1]
    options.MinusSignOnAx = false
    options.InterpolateMissingColors = true
    options.AffectAutoLimits = []
end

DEFAULTCOLORS.basic = {
    [0.0000 0.4470 0.7410]      % blue
    [0.8500 0.3250 0.0980]      % orange
    [0.4660 0.6740 0.1880]      % green
    [0.1000 0.1000 0.1000]      % very dark grey
    [0.9290 0.6940 0.1250]      % burnt yellow
}; 

DEFAULTCOLORS.heat = {
    [0.1000 0.1000 0.1000]      % dark grey
    [0.0000 0.4470 0.7410]      % blue
    [0.4660 0.6740 0.1880]      % green
    [0.8290 0.6940 0.1250]      % burnt yellow
    [0.8000 0.3250 0.0980]      % orange-brown
    [0.9000 0.0000 0.0000]      % strong red
};

if (options.YScaleFactor ~= 1)
    % Warn user if scale factor is being used
    warning(['YScaleFactor is being used (Currently ', ...
        num2str(options.YScaleFactor, '%.0e'), ...
        '). Double-check output to ensure it is intentional.'])
end


if (isempty(options.Axes))
% If an Axes object wasn't specified, create the figure and axes
    fig = figure;
    ax = axes(fig);

    axis tickaligned

    set(fig, ...
        'Units', options.Units, ...
        'Theme', options.Theme, ...
        'Name', options.FigureName, ...
        'Visible', options.Visible)

    % Configure x label
    xlabel(ax, options.XLabel, ...
        'FontSize', options.FontSize, ...
        'FontName', options.FontName, ...
        'Interpreter', options.Interpreter)

    % Configure y label
    ylabel(ax, options.YLabel, ...
        'FontSize', options.FontSize, ...
        'FontName', options.FontName, ...
        'Interpreter', options.Interpreter)

    % Configure other axes options
    set(ax, ...
        'LineWidth', options.LineWidth, ...
        'FontName', options.FontName, ...
        'FontSize', options.NumSize, ...
        'Box', 'on', ...
        'Layer', 'top', ...
        'Units', options.Units, ...
        'PositionConstraint', 'OuterPosition', ...
        'TickLabelInterpreter', options.Interpreter)

    % Set some params if they were specified
    if not(isempty(options.XLim))
        ax.XLim = options.XLim;
    end
    
    if not(isempty(options.YLim))
        ax.YLim = options.YLim;
    end
    
    if not(isempty(options.XTick))
        ax.XTick = options.XTick;
    end
    
    if not(isempty(options.YTick))
        ax.YTick = options.YTick;
    end
    
    if not(isempty(options.YExponent))
        ax.YAxis.Exponent = options.YExponent;
    end
else
    % If an axes object was input, skip all config setting and continue
    ax = options.Axes;
    tempAxPosition = ax.Position();

    fig = ax.Parent;
end

hold on

if not(isempty(options.YAxisLocation))
    % If plotting two y-axes
    yyaxis(ax, options.YAxisLocation)
end

if not(iscell(y))
    % Plot using "line" to reduce chances of overwritting the configuration
    % (however, axes limits might change)
    lin = line(ax, x, y * options.YScaleFactor);
elseif iscell(y)
    if length(y) ~= length(x)
        if isscalar(x) % faster than length(x) == 1
            warning("Only one array for x provided. All y values" + ...
                " will be plotted versus it.")
            % Convert x from cell to array to simplify the code below
            x = x{1};
        else % if y and x have different sizes
            if iscell(x)
                % if x is a cell with different number of arrays: problem
                error("x must have either the same number of arrays" + ...
                    " as y, or have exactly one array.")
            end
        end
    end

    lin = cell([length(y) 1]);
    for i = 1:length(y)
        if iscell(x)
            lin{i} = line(ax, x{i}, y{i} * options.YScaleFactor);
        else
            lin{i} = line(ax, x{1}, y{i} * options.YScaleFactor);
        end
    end
end
hold off

% Add legend if labels were specified
if (not(isempty(options.LegendLabels)))
    legend(ax, options.LegendLabels, ...
        'FontName', options.FontName, ...
        'FontSize', options.FontSize, ...
        'Interpreter', options.Interpreter, ...
        'Location', options.LegendLocation)
end

% Make axis "tight" if limits weren't specified
if isempty(options.XLim) & isempty(options.YLim)
    axis tight
end

% Replace hyphen by minus
if options.MinusSignOnAx
    % X-axis
    xt = get(ax, 'XTickLabel');
    xt = strrep(xt, '-', '−');
    set(ax, 'XTickLabel', xt);
    
    % Y-axis
    yt = get(ax, 'YTickLabel');
    yt = strrep(yt, '-', '−');
    set(ax, 'YTickLabel', yt);
end

% Process Color
if ischar(options.Color)
    if isfield(DEFAULTCOLORS, options.Color)
        options.Color = DEFAULTCOLORS.(options.Color);
    end
end

if not(iscell(options.Color)) && not(ischar(options.Color)) && options.InterpolateMissingColors && length(options.Color) ~= 3
    if length(lin) > length(options.Color)
        colorMat = vertcat(options.Color{:});

        x = linspace(1, size(colorMat, 1), length(lin));
        xi = 1:size(colorMat, 1);
        interpColors = interp1(xi, colorMat, x);

        options.Color = mat2cell(interpColors, ones(1, length(lin)), 3);

        warning("Not enough colors. Interpolating.")
        disp("Interpolated colors = ")
        disp(options.Color)
    end
end

processOptions(lin, 'Color', options.Color)

% Process Markers
processOptions(lin, 'Marker', options.Marker)
processOptions(lin, 'MarkerSize', options.MarkerSize)
processOptions(lin, 'MarkerEdgeColor', options.MarkerEdgeColor)
processOptions(lin, 'MarkerFaceColor', options.MarkerFaceColor)

% Process LineStyle
processOptions(lin, 'LineStyle', options.LineStyle)

% Process AffectAutoLimits
if isempty(options.AffectAutoLimits) && ~isempty(options.Axes)
    % If AffectAutoLimits not specified but another axes object was, set
    % that to false so it doesn't resize the plot
    options.AffectAutoLimits = false;
end

processOptions(lin, 'AffectAutoLimits', options.AffectAutoLimits)

% Adjust exact plot size, if specified
if not(isempty(options.PlotWidth)) && not(isempty(options.AspectRatio))
    PlotHeight = options.PlotWidth/options.AspectRatio;
    ax.InnerPosition([3 4]) = [options.PlotWidth PlotHeight];
    ax.InnerPosition(1) = ax.InnerPosition(1) + ax.TickLength(1);

    ax.YLabel.Units = 'inches';

    fig.InnerPosition([3 4]) = ax.OuterPosition([3 4]) + [ax.YLabel.Extent(3) 0];
end

end


function processOptions(object, prop, value)

arguments
    object
    prop (1,1) string
    value
end

if isempty(value); return; end

if iscell(value)
    if iscell(object)
        % Both the option and the object are cells
        if length(value) > length(object)
            warning(append(num2str(length(value)), " values of ", prop, " were passed, but only ", num2str(length(object)), " were necessary. Ignoring extras."))
        end
        
        for i = 1:length(object)
            try
                set(object{i}, prop, value{i})
            catch err
                if strcmpi(err.identifier, 'MATLAB:badsubscript')
                    warning(append("Not enough ", prop, " values were passed. Repeating last entry."))
                    set(object{i}, prop, value{end})
                else
                    rethrow(err)
                end
            end
        end
    else
        % Only the option is a cell
        warning(append("Multiple ", prop, " values were passed when only one was necessary. Ignoring extras."))
        set(object, prop, value{1})
    end
else
    if iscell(object)
        % Only object was passed as cell
        for i = 1:length(object)
            set(object{i}, prop, value)
        end
    else
        % Neither were passed as cells
        set(object, prop, value)
    end
end


end