function segmentation = watershedSeg_v2_cortex( aff, cell)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

tRange = cell{1};
vRange = cell{2};

fgm1 = aff < tRange;
fgm1 = bwareaopen(fgm1, vRange, 26);
affImposed = imimposemin(aff, fgm1);
segmentation= watershed(affImposed, 26);

end
