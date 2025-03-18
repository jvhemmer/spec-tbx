function copyFile(destination, source)
%COPYFILE Copies multiple from the source path to multiple distinations.
%
%   Encapsulates the copyfile function of MATLAB to facilitate
%   understanding and improve code readability. Useful for copying all the 
%   input data files and also export them.

arguments
    destination (1,:)
end

arguments (Repeating)
    source (1,:) cell
end

for i = 1:length(source) 
    if iscell(source{i})
        nFiles = length(source{i});
        for j = 1:nFiles
            copyfile(source{i}{j}, destination)
        end
    else
        copyfile(source{i}, destination)
    end
end