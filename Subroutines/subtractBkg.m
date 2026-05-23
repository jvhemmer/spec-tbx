function corrected = subtractBkg(data, bkg, options)
% subtractBkg: subtracts an interpolated (or raw) background from input data
%
%   Arguments:
%     data : vector or cell of vectors
%     bkg  : vector or cell of vectors
%
%   Optional:
%     Interpolate   : logical, if true stretches bkg to data length (default false)
%     AverageEveryN : integer, number of bkg's to average before subtracting (default 0)
%
%   Output:
%     corrected : cell array of same size as data, each entry = data – bg

    arguments
        data
        bkg
        options.Interpolate   (1,1) logical = false
        options.AverageEveryN (1,1) double  = 0
    end

    % Wrap scalars into cells
    if ~iscell(data), data = {data}; end
    if ~iscell(bkg),  bkg  = {bkg};  end

    % Average backgrounds if requested
    if options.AverageEveryN > 0
        N    = options.AverageEveryN;
        nBkg = numel(bkg);
        if mod(nBkg, N) ~= 0
            error("Number of backgrounds (%d) must be a multiple of %d.", nBkg, N)
        end
    
        nGroups = nBkg / N;
        avgBkg   = cell(nGroups,1);
    
        for g = 1:nGroups
            idx = (g-1)*N + (1:N);

            % Target length = length of the first bg in this group
            M   = numel(bkg{idx(1)});
            mat = zeros(M, N);

            % Normalized grid for the target
            xT  = linspace(0, 1, M);
    
            for j = 1:N
                v = bkg{idx(j)}(:);
                if numel(v) ~= M
                    if options.Interpolate
                        xV = linspace(0, 1, numel(v));
                        v  = interp1(xV, v, xT, 'linear', 'extrap');
                    else
                        error("Background %d in group %d has length %d, expected %d. Set Interpolate=true to auto‐resample.", ...
                              idx(j), g, numel(v), M);
                    end
                end
                mat(:,j) = v;
            end
    
            avgBkg{g} = mean(mat, 2);  % M×1 vector
        end
    
        bkg = avgBkg;
    end


    % prepare output
    corrected = cell(size(data));
    nD = numel(data);
    nB = numel(bkg);

    % dispatch to the right subtraction pattern
    if nD == nB
        % one-to-one subtraction
        for i = 1:nD
            corrected{i} = doSubtract(data{i}, bkg{i}, options);
        end
    elseif nD == 1 && nB > 1
        % one data, many backgrounds → average them
        meanB = mean( cat(1, bkg{:}), 1 );
        corrected{1} = doSubtract(data{1}, meanB, options);
    elseif nD > 1 && nB == 1
        % many data, one background
        for i = 1:nD
            corrected{i} = doSubtract(data{i}, bkg{1}, options);
        end
    else
        error("Invalid combination: %d data arrays vs %d backgrounds.", nD, nB)
    end

    % if user passed in a single array, unwrap the output
    if ~iscellOrig(data)
        corrected = corrected{1};
    end
end

function out = doSubtract(x, y, options)
    % If the same length, just subtract
    if numel(x) == numel(y) && ~options.Interpolate
        out = x - y;
        return
    end

    % Either different lengths or interpolation explicitly requested
    nX = numel(x);
    nY = numel(y);

    xi = linspace(0,1,nX);
    yi = linspace(0,1,nY);

    yInterp = interp1(yi, y, xi, 'linear', 'extrap');
    yInterp = reshape(yInterp, size(x)); % make sure they have the same shape

    out = x - yInterp;
end

function tf = iscellOrig(val)
    % Helper to detect if user originally passed a cell or not
    tf = iscell(val) && isscalar(val) && ~iscell(val{1});
end
