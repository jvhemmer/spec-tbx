function addLegendTitle(legHandle, txt, position, wrap, interpreter)
% addLegendTitle Adds a title string to the top or bottom of a legend.
%
%   addLegendTitle(legHandle, txt, position, wrap, interpreter)
%       legHandle   : handle to the legend (returned by legend(...))
%       txt         : string to display as the title
%       position    : 'top' or 'bottom'
%       wrap        : logical, true = allow wrapping (default), false = disable
%       interpreter : 'tex' (default), 'latex', or 'none'

    if nargin < 3 || isempty(position)
        position = 'top';
    end
    if nargin < 4 || isempty(wrap)
        wrap = true;
    end
    if nargin < 5 || isempty(interpreter)
        interpreter = 'tex';
    end

    % Font settings inherited from legend
    props = {'FontName', legHandle.FontName,'FontSize',legHandle.FontSize};

    % Compute Y offset
    switch lower(position)
        case 'top'
            yPos = legHandle.Position(2) + legHandle.Position(4);
            vAlign = 'bottom';
        case 'bottom'
            yPos = legHandle.Position(2) - 0.05; % small offset down
            vAlign = 'top';
        otherwise
            error('Position must be ''top'' or ''bottom''.');
    end

    % Create annotation textbox
    h = annotation('textbox', ...
        [legHandle.Position(1), yPos, legHandle.Position(3), 0.05], ...
        'String', txt, ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment', vAlign, ...
        'LineStyle','none', ...
        'Interpreter', interpreter, ...
        props{:});

    % Handle wrapping
    if wrap
        h.FitBoxToText = 'off';
    else
        h.FitBoxToText = 'on';
    end
end
