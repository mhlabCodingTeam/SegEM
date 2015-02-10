function segmentation = watershedSeg_v1_cortex( aff, cell )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

hRange = cell{1};                             
vRange = cell{2};

affHmin= imhmin(aff, hRange, 26);
bw1 = imregionalmin(affHmin, 26);
clear affHmin;
bw1 = bwareaopen(bw1, vRange, 26);
affImposed = imimposemin(aff, bw1);
segmentation = watershed(affImposed, 26);

end