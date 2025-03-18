function [outPotential, outCurrent] = getCVCycle(potential, current, numcycles, desiredcycles)
%timeFromCV: Calculates time-based array to plot with current from CV data.
%
%   Arguments:
%       potential:      potential data.
%       current:        current data.
%       numcycles:      number of cycles in the data.
%       desiredcycles:  cycle(s) to get.   

arguments
   potential (1,:)
   current (1,:)
   numcycles (1,1)
   desiredcycles (1,:)
end

% Split potential and current arrays into equal size arrays
splitPotential = splitArray(potential, numcycles);
splitCurrent = splitArray(current, numcycles);

outPotential = [];
outCurrent = [];

for i = 1:length(desiredcycles)
    outPotential = [outPotential splitPotential{desiredcycles(i)}];
    outCurrent = [outCurrent splitCurrent{desiredcycles(i)}];
end
