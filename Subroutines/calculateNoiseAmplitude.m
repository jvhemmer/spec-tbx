function out = calculateNoiseAmplitude(data)
    % Fit a polynomial to the data
    x = (1:length(data))';
    out.coefficients = polyfit(x, data, 3);
    
    % Evaluate the fit at the data points
    out.fitData = polyval(out.coefficients, x);
    
    % Calculate the residuals
    out.residuals = data - out.fitData;
    
    % Calculate the standard deviation of the residuals (noise amplitude)
    out.amplitude = std(out.residuals);
end