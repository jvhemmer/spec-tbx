function filteredCurrent = filterCV(time, current, frequencyRange, options)
% Applies of band stop filter to time-dependent CV/LSV data.
%
%   Arguments:
%       time:           time data (must analyze time-domain, not potential).
%       current:        current data.
%       frequencies:    frequency range that must be filtered out.
%       filterOrder:    filter order.
%       

arguments
   time (1,:)
   current (1,:)
   frequencyRange (1,2)
   options.filterOrder (1,1) = 2
end

% Calculate frequency step. Input current data MUST be of regular intervals
frequencyStep = 1/(time(2) - time(1));

filter = designfilt('bandstopiir', ...
    FilterOrder =           options.filterOrder, ...
    HalfPowerFrequency1 =   frequencyRange(1), ...
    HalfPowerFrequency2 =   frequencyRange(2), ...
    SampleRate =            frequencyStep);

current = filtfilt(filter, current);

filteredCurrent = current;
