function segmentation = watershedSeg_v1_paper( aff, hRange, vRange )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

segmentation = cell([length(hRange) length(vRange)]);
affHmin = cell(size(aff));
for h=1:length(hRange)
    for dir=1:length(aff)
        affHmin{dir} = imhmin(aff{dir}, hRange(h), 26);
    end
    affHminAll = (affHmin{1} + affHmin{2} + affHmin{3}) / 3;
    bw1 = imregionalmin(affHminAll, 26);
    for v=1:length(vRange)
        bw1 = bwareaopen(bw1, vRange(v), 26);
        segmentation{h,v} = watershed_3D(affHmin{1}, affHmin{2}, affHmin{3}, bw1);
    end
end

end

