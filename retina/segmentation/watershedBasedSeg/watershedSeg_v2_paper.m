function segmentation = watershedSeg_v2_paper( aff, tRange, vRange)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

segmentation = cell([length(tRange) length(vRange)]);
affAll = (aff{1} + aff{2} + aff{3}) / 3;
for t=1:length(tRange)
    display(num2str(t));
    fgm1 = affAll < tRange(t);
    for v=1:length(vRange)
        fgm1 = bwareaopen(fgm1, vRange(v), 26);
        segmentation{t,v} = watershed_3D(aff{1}, aff{2}, aff{3}, fgm1);
        % Temporary fix: Grow out!!!
        while any(segmentation{t,v}(:) == 0)
            segTemp = imdilate(segmentation{t,v}, ones(5,5,5));
            borders = segmentation{t,v} == 0;
            segmentation{t,v}(borders) = segTemp(borders);
        end
    end
end

end

