function [fig, ax, lin] = plotXY(x, y, options)
% plotXY: Plot a simple X-Y graph.
%
%   Most of the optional arguments work exactly as they do for the built-in
%   MATLAB graphing functions (e.g., plot, line, bar, mesh, etc.) and thus
%   the original documentation applies here. New optional arguments are
%   explained whenever they are used in the code.
%
%   Created by Johann Hemmer
%   johann.hemmer@louisville.edu
%   github.com/jvhemmer/data-processing
%   17 Aug 2024
%
%   Arguments:
%       x: x-axis data
%       y: y-axis data

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
end

COLOR = {
    [0.0000 0.4470 0.7410]      % blue
    [0.8500 0.3250 0.0980]      % orange
    [0.4660 0.6740 0.1880]      % green
    [0.1000 0.1000 0.1000]      % very dark grey
    [0.9290 0.6940 0.1250]      % burnt yellow
}; 

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

if (options.YScaleFactor ~= 1)
    % Apply scale factor, if specified and warn user just in case
    warning(['YScaleFactor is being used (Currently ', ...
        num2str(options.YScaleFactor, '%.0e'), ...
        '). Double-check output to ensure it is intentional.'])
    y = y * options.YScaleFactor;
end

hold on

if not(isempty(options.YAxisLocation))
    % If plotting two y-axes
    yyaxis(ax, options.YAxisLocation)
end

if not(iscell(y))
    % Plot using "line" to reduce chances of overwritting the configuration
    % (however, axes limits might change)
    lin = line(ax, x, y, ...
        'LineStyle', options.LineStyle, ...
        'Color', options.Color, ...
        'LineWidth', options.LineWidth);
else % if y is a cell array
    lin = cell([length(y) 1]);
    for i = 1:length(y)
        if not(iscell(options.Color))
            warning("Default colors will be used since the Color " + ...
                "argument wasn't passed as a cell array.")
            options.Color = COLOR;
        end

        lin{i} = line(ax, x, y{i}, ...
            'LineStyle', options.LineStyle, ...
            'Color', options.Color{i}, ...
            'LineWidth', options.LineWidth);
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

end