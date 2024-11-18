function saveAllFigs(path, formats)
%saveAllFigs: Saves all open figures provided they have names.
%
%   Arguments:
%       path: folder where the file is to be saved at
%       formats: formats that the figure will be saved at (multiple can
%           be specified simultaneously).   
%           Supported formats: fig, png, pdf, svg
%
%   Example:
%   saveAllFigs('C:/Data/Spectrum', 'png', 'svg', 'pdf')

    arguments
        path (1,:) char
    end

    arguments (Repeating)
        formats (1,:) char
    end

    figs = findobj('Type', 'figure');

    numFigs = length(figs);

    for iFig = 1:numFigs
        fig = figs(iFig);

        if not(isempty(fig.Name))
            name = fig.Name;
        else
            name = ['figure_' num2str(iFig)];
        end

        saveFig(fig, name, path, formats{:})
    end
end
