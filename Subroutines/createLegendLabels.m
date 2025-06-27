function labels = createLegendLabels(conditions, options)
% createLegendLabels: Creates a legend label array cell for experimental
% conditions.
%
%   Arguments:
%       conditions: array containing the conditions of each data.
%   Optional arguments:     
%       Suffix: suffix that will be appended to each label (e.g., unit).


arguments
   conditions (1,:)
   options.Decimals = []
   options.SignificantDigits = []
   options.Suffix = ''
end

labels = cell([1 length(conditions)]);

for i = 1:length(conditions)
    if not(isempty(options.Decimals)) && not(isempty(options.SignificantDigits))
        error('Cannot specify both number of decimal places and significant digits.')
    end

    if not(isempty(options.Decimals))
        formatSpec = append('%.', num2str(options.Decimals), 'f');
        labels{i} = append(num2str(conditions(i), formatSpec), options.Suffix);
    elseif not(isempty(options.SignificantDigits))
        formatSpec = options.SignificantDigits;
        labels{i} = append(num2str(conditions(i), formatSpec), options.Suffix);
    else
        labels{i} = append(num2str(conditions(i)), options.Suffix);
    end    
end
