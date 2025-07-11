function [frame, image] = readCameraMatrix(path, options)
% readCameraMatrix: Reads the output of LightField in matrix form, combines
% the intensities of all pixels and outputs a intensity vs. frame matrix.
%
%   Arguments:
%       path: path to the file to be read. Does not support multiple paths

arguments
    path (1,:) {mustBeA(path, {'char'; 'cell'; 'string'})}
    options.DataHasHeaders = true
end

if iscell(path)
    if isscalar(path)
        path = path{1};
    end
end

disp(append('Opening ', path, '...'))
data = readmatrix(path);

% Length of matrix in x (i.e., width, columns)
x = data(1,end) + 1;

% Length of matrix in y (i.e., height, rows)
y = data(end,1) + 1;

% Total number of frames
if options.DataHasHeaders
    frames = height(data) / (y + 1);
else
    error('case not implemented')
    % frames = height(data) / y;
end

frame = [1:1:frames]';

image = cell([frames 1]);
for i = 1:frames
    xRange = (1 + x * (i - 1) + i):(i + x*i);
    yRange = 2:y + 1;

    image{i} = data(xRange,yRange);
end

end