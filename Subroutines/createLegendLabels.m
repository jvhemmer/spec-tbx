function labels = createLegendLabels(conditions, suffix)
% createLegendLabels: Creates a legend label array cell for experimental
% conditions.
%
%   Arguments:
%       conditions: array containing the conditions of each data.
%       suffix:     suffix that will be appended to each label (e.g., unit).


arguments
   conditions (1,:)
   suffix (1,:)
end

labels = cell([1 length(conditions)]);

for i = 1:length(conditions)
    labels{i} = append(num2str(conditions(i)), suffix);
end
