function out = stretch(vector,factor)
%STRETCH Summary of this function goes here
%   Detailed explanation goes here

% Calculate the center of the vector (mean of the first and last elements)
center = (vector(1) + vector(end)) / 2;

% Shift the vector so the center is at 0
vector_shifted = vector - center;

% Scale the vector
vector_stretched = vector_shifted * factor;

% Shift the vector back to the original center
out = vector_stretched + center;

end