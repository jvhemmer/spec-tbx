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
