function [out] = mirroredSGolayFilt(y, polynomialDegree, windowSize)
% mirroredSGolayFilt Summary of this function goes here
%   Detailed explanation goes here

arguments
    y (:,1)
    polynomialDegree
    windowSize
end

mirrorLength = floor(windowSize/2);

yExtended = vertcat(flip(y(1:mirrorLength)), y, flip(y(end-mirrorLength+1:end)));

yFilteredExtended = sgolayfilt(yExtended, polynomialDegree, windowSize);

yFiltered = yFilteredExtended(mirrorLength+1:end-mirrorLength);

out = yFiltered;
end