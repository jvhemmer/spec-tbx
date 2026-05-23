function [out] = nDerivative(x, y, n, options)
% nDerivative: calculate the nth derivative.

arguments
    x (:,1)
    y (:,1)
    n (1,1)
    options.Plot = false
    options.OutputOnlyLastDerivative = true
    options.Smoothing = true
    options.SmoothingPolynomialDegree = 5
    options.SmoothingWindowSize = 0
end

% If window size was not specified, make it 10% of the total number of
% datapoints.
if options.SmoothingWindowSize == 0
    w = floor(length(x) * 0.1);
    if (mod(w,2) == 0), w = w + 1; end % must be odd
    options.SmoothingWindowSize = w;
end
    
y = sgolayfilt(y, ...
    options.SmoothingPolynomialDegree, ...
    options.SmoothingWindowSize);

figure
plot(x,y)
nder = cell([n 1]);

nder{1} = gradient(y,x);

if options.Plot == true
    figure
    plot(x, nder{1})
end

if n > 1
    for i = 2:n
        smoothY = sgolayfilt(nder{i-1}, ...
            options.SmoothingPolynomialDegree, ...
            options.SmoothingWindowSize);

        nder{i} = gradient(smoothY, x);

        if options.Plot == true
            hold on
            plot(x, nder{i})
        end
    end
    hold off
end

if options.OutputOnlyLastDerivative
    out = nder{end};
else
    out = nder;
end

