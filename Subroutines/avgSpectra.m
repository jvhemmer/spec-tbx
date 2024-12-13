function avgIntensity = avgSpectra(intensity, options)
% avgSpectra: Average of time-dependent spectra.

    arguments
        intensity (:,:)
        options.FrameRange (2,1) = [NaN, NaN]
    end

    if any(isnan(options.FrameRange))
        % If FrameRange was not specified, average over all frames
        frames = [1 size(intensity, 2)];
    else
        frames = options.FrameRange;
    end

    % Sum spectra of each frame into one spectrum
    sumIntensity = sum(intensity(:, frames(1):frames(2)), 2);

    % Calculate number of frames
    numFrames = frames(end) - frames(1) + 1;

    % Divide sum by number of frames to get average
    avgIntensity = sumIntensity ./ numFrames;
end