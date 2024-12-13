function [area, QC] = integratePeak(x, y, limits)

    arguments
        x (:,1)
        y (:,1)
        limits (1,2)
    end

    startX = limits(1);
    endX = limits(2);

    % Find closest
    [~, startIdx] = min(abs(x - startX));
    [~, endIdx] = min(abs(x - endX));

    % startIdx = find(x == startX);
    % endIdx = find(x == endX);

    % Get the indices of the baseline
    baselineIdx = x >= startX & x <= endX;
    
    % Get the Raman shift values of the baseline
    baselineX = x(baselineIdx);
    
    % Create a baseline of intensity values based of the number of elements
    % in the baseline
    baselineLength = length(baselineX);
    baselineY = linspace(y(startIdx), y(endIdx), baselineLength);
    
    % Integrate numerically to get the total area under the curve
    totalPeakArea = trapz(y(startIdx:endIdx));
    
    % Get the area under the baseline
    baselineArea = trapz(baselineY);
    
    % Subtract to get only the area of the peak
    area = totalPeakArea - baselineArea;

    % Save QC data
    QC.limits = limits;
    QC.baselineX = baselineX;
    QC.baselineY = baselineY;
    QC.totalArea = totalPeakArea;
    QC.baselineArea = baselineArea;
end