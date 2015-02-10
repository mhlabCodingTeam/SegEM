function k = plotOriginalData( rawData, slicePos )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
k = slice(single(rawData), slicePos{1}, slicePos{2}, slicePos{3});
colormap(gray(256));
set(k, 'FaceColor', 'interp', 'EdgeColor', 'none');
end

