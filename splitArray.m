function [out] = splitArray(array, n)
%splitArray: Split array into n arrays of equal size.
%
%   Arguments:
%       array:  array to be split. Must be one dimensional.
%       n:      number of arrays of equal size to split the original array
%       into. Must be integer.

arguments
   array (1,:)
   n (1,1)
end

len = length(array);

out = cell([n 1]);

for i = 1:n
    range = (i - 1) * (len / n) + 1:i * len / n;
    out{i} = array(range);
end