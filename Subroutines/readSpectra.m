function [wavelength, intensity] = readSpectra(path, options)
% readSpectra: Read spectra from LightField and returns wavelength and
% intensity arrays. 
%   
%   The output intensity is automatically reshaped, i.e., it is a n-by-m 
%   matrix where n is the number of x pixels of the camera (usually 1024) 
%   and m is the total number of frames. Consequently, there is one
%   spectrum for each frame. Depending on how the raw data is exported from
%   LightField, the FrameColumn and XWidthColumn might have to be specified
%   as different than the default values. Check the raw data for that.
%   FrameColumn is the column in the raw data that has the frame
%   information and XWidthColumn is the one that has pixel information.
%
%   Arguments:
%       path: path to the file to be read. Does not support multiple paths
%       Background: (optional) not implemented
%       FrameRange: (optional) range of frames to get the data from
%       XWidth: (optional) number of x-pixels of the camera
%       FrameColumn: (optional) column of raw data that has frames
%       XWidthColumn: (optional) column of raw data that has x-pixels

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