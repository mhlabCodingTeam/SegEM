function markers = watershedSegMarkersHmin2D( aff, h, ao )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

affHmin= imhmin(aff, h, 4);
bw1 = imregionalmin(affHmin, 4);
markers = bwareaopen(bw1, ao, 4);

end