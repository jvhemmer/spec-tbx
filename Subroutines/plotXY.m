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
end

COLOR = {
    [0.0000 0.4470 0.7410]      % blue
    [0.8500 0.3250 0.0980]      % orange
    [0.4660 0.6740 0.1880]      % green
    [0.1000 0.1000 0.1000]      % very dark grey
    [0.9290 0.6940 0.1250]      % burnt yellow
}; 

TEMPERATURE_COLOR = {
    [0.1000 0.1000 0.1000]      % dark grey
    [0.0000 0.4470 0.7410]      % blue
    [0.4660 0.6740 0.1880]      % green
    [0.9290 0.6940 0.1250]      % burnt yellow
    [0.8500 0.3250 0.0980]      % orange
};

if (options.YScaleFactor ~= 1)
    % Warn user if scale factor is being used
    warning(['YScaleFactor is being used (Currently ', ...
        num2str(options.YScaleFactor, '%.0e'), ...
        '). Double-check output to ensure it is intentional.'])
end

if length(options.Color) < 2
    if not(ischar(options.Color))
        % If not a char, it should be the index of the COLOR cell
        options.Color = COLOR{options.Color};
    end
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

    % Adjust exact plot size, if specified
    if not(isempty(options.PlotWidth)) && not(isempty(options.AspectRatio))
        PlotHeight = options.PlotWidth/options.AspectRatio;
        ax.Position([3 4]) = [options.PlotWidth PlotHeight];
        fig.Position([3 4]) = ax.OuterPosition([3 4]);
        ax.OuterPosition(1) = ax.OuterPosition(1) + ax.TickLength(1);
    end
else
    % If an axes object was input, skip all config setting and continue
    ax = options.Axes;
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
    lin = line(ax, x, y * options.YScaleFactor, ...
        LineStyle = options.LineStyle, ...
        LineWidth = options.LineWidth, ...
        Color = options.Color, ...
        Marker = options.Marker, ...
        MarkerSize = options.MarkerSize, ...
        MarkerEdgeColor = options.MarkerEdgeColor, ...
        MarkerFaceColor = options.MarkerFaceColor);
else % if y is a cell array
    if not(iscell(x))
        error("x must be a cell if y is also passed as one.")
    else
        if length(y) ~= length(x)
            if isscalar(x) % faster than length(x) == 1
                warning("Only one array for x provided. All y values" + ...
                    " will be plotted vs. it.")
                % Convert x from cell to array to simplify the code below
                x = x{1};
            else
                error("x must have either the same number of arrays" + ...
                    " as y, or have exactly one array.")
            end
        end
    end

    lin = cell([length(y) 1]);
    for i = 1:length(y)
        if not(iscell(options.Color))
            warning("Default colors will be used since the Color " + ...
                "argument wasn't passed as a cell array.")
            options.Color = COLOR;
        end

        if iscell(x)
            lin{i} = line(ax, x{i}, y{i} * options.YScaleFactor, ...
                LineStyle = options.LineStyle, ...
                LineWidth = options.LineWidth, ...
                Color = options.Color{i}, ...
                Marker = options.Marker, ...
                MarkerSize = options.MarkerSize, ...
                MarkerEdgeColor = options.MarkerEdgeColor, ...
                MarkerFaceColor = options.MarkerFaceColor);
        else
            lin{i} = line(ax, x, y{i} * options.YScaleFactor, ...
                LineStyle = options.LineStyle, ...
                LineWidth = options.LineWidth, ...
                Color = options.Color{i}, ...
                Marker = options.Marker, ...
                MarkerSize = options.MarkerSize, ...
                MarkerEdgeColor = options.MarkerEdgeColor, ...
                MarkerFaceColor = options.MarkerFaceColor);
        end
    end
end
hold off

if (not(isempty(options.LegendLabels)))
    % Add legend if labels were specified
    legend(ax, options.LegendLabels, ...
        'FontName', options.FontName, ...
        'FontSize', options.FontSize, ...
        'Interpreter', options.Interpreter, ...
        'Location', options.LegendLocation)
end

if isempty(options.XLim) & isempty(options.YLim)
    axis tight
end

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


end