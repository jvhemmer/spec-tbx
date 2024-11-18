function [limits, QC] = findPeakLimits(x, y, options)

    arguments
        x (:,1)
        y (:,1)
        options.minProminence (1,1) = 0.25
        options.window = ''
    end
    
    Dy = diff(y) ./ diff(x); % First derivative dy/dx
    
    % Apply SGF to smooth before second derivative. A greater window for
    % filtering of the second derivative usually results in more
    % accurate peak intervals. However, if the window is too large,
    % artifacts may be introduced.
    if isempty(options.window)
        options.window = round(length(y)/3, 0);
        if mod(options.window, 2) == 0
            options.window = options.window + 1; % must be odd
        end
    end

    smoothDy = sgolayfilt(Dy, 2, options.window);
    
    % Perform second derivative on smoothed first derivative
    D2y = diff(smoothDy) ./ diff(x(1:end-1));

    smoothD2y = sgolayfilt(D2y, 2, options.window);
    
    % Normalize the second derivative so the peaks can be filtered by
    % prominence (otherwise MATLAB finds too many peaks)
    normD2y = normalize(smoothD2y, 'range', [-1 1]);
    
    % Find peaks in the second derivative graph. There should be two peaks 
    % corresponding to the start and end of the original peak, respectively,
    % and one valley corresponding to the maximum of the original peak (which
    % is not obtained from here.
    [peaks, locs] = findpeaks(normD2y, x(1:end-2), ...
        'MinPeakProminence', options.minProminence);
    
    % If no second derivative peaks were found, there's probably no peaks
    if isempty(peaks)
        % Peaks couldn't be found.
        limits = [NaN, NaN];
    else
        % Find the x-value of the tallest and second tallest peaks
        tallest = locs(peaks==max(peaks));
        secondTallest = locs(peaks==max(peaks(peaks<max(peaks))));
        
        % Peak start is the one with lowest x-value, and vice versa
        peakStart = min(tallest, secondTallest);
        peakEnd = max(tallest, secondTallest);

        % Get peak limits
        limits = [peakStart peakEnd];
    end

    % Export data for QC
    QC.x = x(1:end-2); % X-values for 2 derivative
    QC.y = normD2y; % Normalized second derivative values
end