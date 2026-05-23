function filteredCurrent = filterCV(time, current, frequencyRange, options)
% Applies of band stop filter to time-dependent CV/LSV data.
%
%   Arguments:
%       time:           time data (must analyze time-domain, not potential).
%       current:        current data.
%       frequencyRange: frequency range(s) that must be filtered out.
%       filterOrder:    filter order.
%       

arguments
   time (:,1)
   current (:,1)
   frequencyRange
   options.filterOrder (1,1) = 2
end

% Calculate frequency step. Input current data MUST be of regular intervals
frequencyStep = 1/(time(2) - time(1));

if ~iscell(frequencyRange); frequencyRange = {frequencyRange}; end

for i = 1:length(frequencyRange)
    filter = designfilt('bandstopiir', ...
        FilterOrder =           options.filterOrder, ...
        HalfPowerFrequency1 =   frequencyRange{i}(1), ...
        HalfPowerFrequency2 =   frequencyRange{i}(2), ...
        SampleRate =            frequencyStep);
    
    current = filtfilt(filter, current);
    
    filteredCurrent = current;
end

end