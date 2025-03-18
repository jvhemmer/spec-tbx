function [area, QC] = integratePeak(x, y, limits, options)
% integratePeak: calculates the area under a curve using numerical
% integration, and subtracts the area under the baseline.

    arguments
        x (:,1)
        y (:,1)
        limits (1,2)
        options.debug = false
    end

    startX = min(limits);
    endX = max(limits);

    % Find closest
    [~, startIdx] = min(abs(x - startX));
    [~, endIdx] = min(abs(x - endX));

    if startIdx > endIdx
        warning("x values appear to be in descending order. " + ...
            "Reverting x and y values.")
        x = x(end:-1:1);
        y = y(end:-1:1);

        % Find closest again
        [~, startIdx] = min(abs(x - startX));
        [~, endIdx] = min(abs(x - endX));
    end

    % startIdx = find(x == startX);
    % endIdx = find(x == endX);

    % Get the indices of the baseline
    baselineIdx = x >= startX & x <= endX;
    
    % Get the Raman shift values of the baseline
    baselineX = x(baselineIdx);
    
    % Create a baseline of intensity values based of the number of elements
    % in the baseline
    baselineLength = length(baselineX);
    baselineY = linspace(y(startIdx), y(endIdx), baselineLength)';
    
    % Integrate numerically to get the total area under the curve
    totalPeakArea = trapz(x(startIdx:endIdx), y(startIdx:endIdx));
    
    % Get the area under the baseline
    baselineArea = trapz(baselineX, baselineY);
    
    % Subtract to get only the area of the peak
    area = totalPeakArea - baselineArea;

    % Save QC data
    QC.limits = limits;
    QC.baselineX = baselineX;
    QC.baselineY = baselineY;
    QC.totalArea = totalPeakArea;
    QC.baselineArea = baselineArea;

    if options.debug == true
        [fig, ax] = plotXY(x, y, ... 
            'AspectRatio', 1.2, ...
            'PlotWidth', 5, ...
            'FigureName', 'integrationDebug');

        % Fill area under the curve
        xCoords = [baselineX', fliplr(x(startIdx:endIdx)')];
        yCoords = [baselineY', fliplr(y(startIdx:endIdx)')];

        xCoordsBaseline = [baselineX', fliplr(baselineX')];
        yCoordsBaseline = [baselineY', zeros(size(baselineY))'];

        % Use the fill function to create the filled area plot
        hold(ax, 'on')
        baselineFill = fill(ax, xCoordsBaseline, yCoordsBaseline, ...
            [0.8500 0.3250 0.0980], ...
            'FaceAlpha', 0.5, ...
            'EdgeColor', 'none');

        peakFill = fill(ax, xCoords, yCoords, ...
            [0 0.4470 0.7410], ...
            'FaceAlpha', 0.5, ...
            'EdgeColor', 'none');

        uistack(peakFill, 'bottom'); % Ensure the filled area is behind the plots
        uistack(baselineFill, 'bottom'); % Ensure the filled area is behind the plots

        legend('Baseline', 'Peak', 'Data', Location='best')

        hold(ax, 'off')
    end


end