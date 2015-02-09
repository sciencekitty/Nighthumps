function [ hach, vars ] = hach2mat ( filepath, folders )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

for i = 1:length(folders)
    folder = folders{i};
    folder = sprintf('%s''%s',filepath,folder);
    tmpf = dir(folder);
    sz = size(tmpf);
    
    for ii = 1:sz(1)
    files = [files;tmpf];
    end
end

for i = 1:length(files)
    
end
    