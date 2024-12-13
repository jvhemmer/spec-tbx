function copyFile(destination, source)
%COPYFILE Summary of this function goes here
%   Detailed explanation goes here

arguments
    destination (1,:)
end

arguments (Repeating)
    source
end

n = length(source);
for i = 1:n
    if iscell(source{i})
        nFiles = length(source{i});
        for j = 1:nFiles
            copyfile(source{i}{j}, destination)
        end
    else
        copyfile(source{i}, destination)
    end
end