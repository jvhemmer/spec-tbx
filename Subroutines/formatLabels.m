function formatLabels(ax, varargin)
% Not tested for figures that contain multiple axes.

arguments
    ax
end

arguments (Repeating)
    varargin
end

defaults = dictionary;

defaults('FontName') = 'Arial';
defaults('FontSize') = 20;
defaults('Interpreter') = 'tex';

if mod(length(varargin), 2) ~= 0
    error('Number of provided arguments must be even (i.e., key-val).')
end

for 1:length(varargin/2)

end

end