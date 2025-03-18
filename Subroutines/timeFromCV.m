function time = timeFromCV(potential, scanRate)
% timeFromCV: Calculates time-based array to plot with current from CV data.
%
%   Arguments:
%       current:    current data.
%       potential:  potential data.
%       scanRate:   scan rate, in V/s
%       

arguments
   potential (1,:)
   scanRate (1,1)
end

potentialStep = abs(potential(2) - potential(1));

timeStep = potentialStep / scanRate;

totalTime = length(potential) * timeStep;

time = timeStep:timeStep:totalTime;
