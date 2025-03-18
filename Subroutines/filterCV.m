function filteredCurrent = filterCV(time, current, frequencies, options)
%timeFromCV: Calculates time-based array to plot with current from CV data.
%
%   Arguments:
%       time:           time data (must analyze time-domain, not potential).
%       current:        current data.
%       frequencies:      frequency that must be filtered out.
%       filterRange:    range of frequencies about the desired frequency
%                       that will be filtered. For example, for a filter at
%                       20 Hz with a range of 2 Hz, the frequencies 18‒22
%                       Hz will be filtered out (default 1 Hz).
%       

arguments
   time (1,:)
   current (1,:)
   frequencies (1,:)
   options.filterRange (1,1) = 1
   options.filterOrder (1,1) = 2
end

% Calculate frequency step. Input current data MUST be of regular intervals
frequencyStep = 1/(time(2) - time(1));

for i = 1:length(frequencies)
    filter = designfilt('bandstopiir', ...
        FilterOrder =           options.filterOrder, ...
        HalfPowerFrequency1 =   frequencies(i) - options.filterRange, ...
        HalfPowerFrequency2 =   frequencies(i) + options.filterRange, ...
        SampleRate =            frequencyStep);

    current = filtfilt(filter, current);
end

filteredCurrent = current;
