function [peakPos, peakArea, QC] = integrateFrameByFrame(x, y, options)
%INTEGRATEFRAMEBYFRAME Summary of this function goes here
%   Detailed explanation goes here

    arguments
        x (:,1)
        y (:,:)
        options.FrameRange (2,1) = [NaN, NaN]
        options.MinimumSNR = 3
        options.PolynomialDegree (1,1) = 2
        options.WindowSize (1,1) = 7
        options.PeakRange (2,1) = [NaN, NaN]
        options.NoiseRange (2,1) = [NaN, NaN]
        options.MinPeakProminence (1,1) = 0
        options.Visible = 'on'
        options.TargetPeakPos = []
        options.TargetPeakPosTolerance = 0.02 % Percentage
    end

    warning('off')

    ASPECT_RATIO = 1.2;
    PLOT_WIDTH = 5;

    % Preallocate
    frames = size(y, 2);
    xwidth = size(y, 1);

    if any(isnan(options.PeakRange))
        peakRange = [min(x) max(x)];
    else
        peakRange = options.PeakRange;
    end

    peakPos = zeros(frames, 1);
    peakArea = zeros(frames, 1);

    QC.ySmooth = nan(xwidth, frames);
    QC.baseline = cell([frames 1]);

    % Loop each frame
    for frame = 1:frames
        % Get indices withing the specified Raman Shift range
        idxRange = x >= peakRange(1) & x <= peakRange(2);

        % Get only the range of values we care about
        yRange = y(idxRange, frame);
        xRange = x(idxRange);
        
        % Smoothing using Savitzky-Golay Filter
        polynomialDegree = options.PolynomialDegree;
        windowSize = options.WindowSize;
        
        % Adjust windowSize if data length is lower than it
        while length(yRange) < windowSize
            windowSize = windowSize - 2;
        end
    
        ySmooth = sgolayfilt(yRange, polynomialDegree, windowSize);
    
        if not(any(isnan(options.NoiseRange)))
            % If noise range was specified by user
            noiseRange = options.NoiseRange;

            noiseIdxRange = x >= noiseRange(1) & x <= noiseRange(2);
            xNoiseRange = x(noiseIdxRange);
            yNoiseRange = y(noiseIdxRange);
        
            noise = calculateNoiseAmplitude(yNoiseRange);

            minProm = noise.amplitude * options.MinimumSNR;
        else
            minProm = options.MinPeakProminence;
        end
    
        % Find the peak within the range
        [pks, locs, ~, prom] = findpeaks(ySmooth, xRange, ...
            'MinPeakProminence', minProm);
        
        % The peak position is the Raman Shift value where MATLAB found the peak
        % with the highest prominence
        peak = locs(prom == max(prom));
        if isempty(peak)
            peakArea(frame) = 0;
            peakPos(frame) = NaN;
        else
            peakPos(frame) = peak;
        end
        
        if isempty(peakPos(frame)) || isnan(peakPos(frame))
            % If peak not found
            peakFound = false;
            peakArea(frame) = 0;
            peakPos(frame) = NaN;

            warning(char(["No peaks found on frame " num2str(frame)]))
        else
            if not(isempty(options.TargetPeakPos))
            % If user provided a target peak position
            peakPosLowerTolerance = options.TargetPeakPos * (1 - options.TargetPeakPosTolerance);
            peakPosUpperTolerance = options.TargetPeakPos * (1 + options.TargetPeakPosTolerance);
                    
                if peakPos(frame) > peakPosUpperTolerance || peakPos(frame) < peakPosLowerTolerance
                    % If peak is outside of provided tolerance
                    peakFound = false;
                    warning(char(["Peak outside tolerance on frame " num2str(frame)]))
                else
                    peakFound = true;
                end
            else
                peakFound = true;
            end
        end

        if peakFound
            % Intensity (maximum) of the peak
            peakY = pks(prom == max(prom));
            
            % Finding peak limits
            [limits, derData] = findPeakLimits(xRange, ySmooth, ...
                'minProminence', 0.2);
        
            if not(any(isnan(limits))) && not(isempty(limits))
                xStart = limits(1);
                xEnd = limits(2);
  
                startIdx = find(xRange==xStart);
                endIdx = find(xRange==xEnd);
    
                % If the peak is outsite the range of the peak start and end found by
                % the second derivative, then probably there's no peak or the data is
                % too noisy.
                if peakPos(frame) > xEnd || peakPos(frame) < xStart
                    peakFound = false;
                    warning(char(["Peak outside range on frame " num2str(frame)]))
                end
        
                % Integrating. CHECK Y FOR SMOOTH OR RAW
                [peakArea(frame), integration] = integratePeak( ...
                    xRange, ySmooth, limits);

                QC.baseline{frame} = {integration.baselineX; integration.baselineY};
            else
                peakFound = false;

                warning(char(["Limits couldn't be found on frame " num2str(frame)]))

                peakArea(frame) = 0;
                peakPos(frame) = NaN;
            end
        end
    end

    %% Plotting
    % Create a figure to show the second derivative
    if peakFound
        % FIX LATER
        [fig1, ax1] = plotXY(derData.x, derData.y, ...
            'XLabel', 'Raman shift (cm^{−1})', ...
            'YLabel', 'd^{2}{\itI}/d\nu^{2} (normalized)', ...
            'AspectRatio', ASPECT_RATIO, ...
            'PlotWidth', PLOT_WIDTH, ...
            'FigureName', 'derivative', ...
            'Visible', options.Visible);
    
        if peakFound
            margin = 0.985;
            XLimits = [xStart*margin xEnd*(1 + (1 - margin))];
            set(ax1, 'XTick', round([xStart xEnd], 0))
        else
            XLimits = peakRange;
        end
    
        set(ax1, 'XLim', XLimits)

        QC.fig1 = fig1;
    end

    % Create a figure to show the identified peak and integration
    [fig2, ax2, p] = plotXY(xRange, ySmooth, ...
        'XLabel', 'Raman shift (cm^{−1})', ...
        'YLabel', 'Intensity (counts)', ...
        'FigureName', 'integration', ...
        'AspectRatio', ASPECT_RATIO, ...
        'PlotWidth', PLOT_WIDTH, ...
        'XLim', [min(xRange) max(xRange)], ...
        'Visible', options.Visible);

    if peakFound
        ax2.XTick = round([xStart peakPos(frame) xEnd], 0);

        plotXY(integration.baselineX, integration.baselineY, ...
            'Color', 'k', ...
            'LineStyle', '--', ...
            'Axes', ax2);
    
        % Plot line last so it doesn't rescale the plot
        line(ax2, ...
            round([peakPos(frame) peakPos(frame)], 0), [ax2.YLim(1) peakY], ...
            'Color', [0.75 0.75 0.75], ...
            'LineStyle', '--');

        uistack(p, 'top') % Bring main curve to the front

        % Fill area under the curve
        xCoords = [integration.baselineX', fliplr(xRange(startIdx:endIdx)')];
        yCoords = [integration.baselineY, fliplr(ySmooth(startIdx:endIdx)')];

        % Use the fill function to create the filled area plot
        hold(ax2, 'on')
        filledArea = fill(ax2, xCoords, yCoords, ...
            [0 0.4470 0.7410], ...
            'FaceAlpha', 0.1, ...
            'EdgeColor', 'none');

        uistack(filledArea, 'bottom'); % Ensure the filled area is behind the plots
        hold(ax2, 'off')
    end

    % Plot unfiltered data as comparison
    [fig3, ax3] = plotXY(xRange, yRange, ...
        'XLabel', 'Raman shift (cm^{−1})', ...
        'YLabel', 'Intensity (counts)', ...
        'AspectRatio', ASPECT_RATIO, ...
        'PlotWidth', PLOT_WIDTH, ...
        'FigureName', 'smoothing', ...
        'Visible', options.Visible);

    plotXY(xRange, ySmooth, ...
        'Color', 'k', ...
        'Axes', ax3);

    legend(ax3, {'Original', 'Smooth'}, ...
        'Location', 'best')

    if not(any(isnan(options.NoiseRange)))
        % Plot noise region
        [fig4, ax4] = plotXY(xNoiseRange, yNoiseRange, ...
            'XLabel', ax2.XLabel.String, ...
            'YLabel', ax2.YLabel.String, ...
            'AspectRatio', ASPECT_RATIO, ...
            'PlotWidth', PLOT_WIDTH, ...
            'FigureName', 'noise', ...
            'Visible', options.Visible);
    
        plotXY(xNoiseRange, noise.fitData, ...
            'Color', 'k', ...
            'LineStyle', '--', ...
            'Axes', ax4);
    
        legend(ax4, {'Original', 'Fit Data'}, ...
            'Location', 'best')
    
        upperBound = yNoiseRange + options.MinimumSNR * noise.amplitude;
        lowerBound = yNoiseRange;
    
        hold(ax4, 'on')
        fill([xNoiseRange; flipud(xNoiseRange)], ...
            [lowerBound; flipud(upperBound)], ...
            'r', ...
            'FaceAlpha', 0.2, ...
            'EdgeColor', 'none', ...
            'DisplayName', [num2str(options.MinimumSNR) '{\it\sigma}']);
        hold(ax4, 'off')

        QC.fig4 = fig4;
    end

    QC.fig2 = fig2;
    QC.fig3 = fig3;
end