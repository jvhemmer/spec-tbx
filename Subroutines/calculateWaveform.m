function [potential, time] = calculateWaveform(Ei, Ef, samplingRate, scanRate, segments)
%CALCULATEWAVEFORM Summary of this function goes here
%   Detailed explanation goes here

arguments
    Ei (1,1) double
    Ef (1,1) double
    samplingRate (1,1) double
    scanRate (1,1) double = []
    segments (1,1) double = 1
end

sampleTime = 1/samplingRate;

if isempty(scanRate)
    % if scanRate wasn't specified, assume it is CA
    % DO LATER
else
    if segments == 1
        % if scanRate was specified, assume it is either LSV or CV
        segmentTime = abs(Ef - Ei) / scanRate;
    
        samplesPerSegment = segmentTime * samplingRate;
    
        % Calculate time array
        ti = sampleTime;
        tf = segmentTime * segments;
    
        time = ti:sampleTime:(tf + eps(tf));
        time = time';

        potential = linspace(Ei, Ef, samplesPerSegment + eps(samplesPerSegment));

    elseif segments > 1
        % if segments > 1, assume it is CV
        segmentTime = abs(Ef - Ei) / scanRate;
    
        samplesPerSegment = segmentTime * samplingRate;
    
        % Calculate time array
        ti = sampleTime;
        tf = segmentTime * segments;
    
        time = ti:sampleTime:(tf + eps(tf));
        time = time';
    
        potential = [];
        for seg = 1:segments
            % Cycle all segments
            if mod(seg, 2) == 1
                % If current segment is odd (going from Ei to Ef)
                segmentPotential = linspace(Ei, Ef, samplesPerSegment + eps(samplesPerSegment));
            else
                % If current segments i even (going from Ef to Ei)
                segmentPotential = linspace(Ef, Ei, samplesPerSegment + eps(samplesPerSegment));
            end
    
            potential = [potential segmentPotential];
        end
        potential = potential';
    end
end

end