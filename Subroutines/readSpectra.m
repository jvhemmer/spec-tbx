function [wavelength, intensity] = readSpectra(path, options)
%avgSpectra: Summary of this function goes here
%   Detailed explanation goes here

    arguments
        path (1,:) {mustBeA(path, {'char'; 'cell'; 'string'})}
        options.Background = []
        options.FrameRange (2,1) = [NaN, NaN]
        options.XWidth = [];
        options.FrameColumn = 3;
        options.XWidthColumn = 6;
    end
    
    if iscell(path)
        if isscalar(path)
            path = path{1};
        end
    end

    [wavelength, intensity, frame, xpixel] = readData(path, ...
        1, 2, options.FrameColumn, options.XWidthColumn);

    if (isempty(options.XWidth))
        XWidth = xpixel(end) + 1;
    else
        XWidth = options.XWidth;
    end

    wavelength = wavelength(1:XWidth);

    % Total number of frames
    Frames = frame(end);

    % Reshape intensity matrix to get one frame per column
    intensity = reshape(intensity, [XWidth Frames]); 

    if not(isempty(options.FrameRange)) && not(any(isnan(options.FrameRange)))
        intensity = intensity(:, options.FrameRange);
    end
end