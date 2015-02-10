function visualizeObjHist( general, segmentation, cutoff, iRange, jRange, kRange )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

for i=iRange
    for j=jRange
        for k=kRange
            figure('position', [1 41 1600 784]);
            sizeObj = hist(single(segmentation{i,j,k}(:)),1:general(i,j,k).maxNrObjects);
            sizeObj(sizeObj > cutoff) = cutoff;
            hist(single(sizeObj), 250:500:(cutoff - 250));
            xlabel('Object Size [voxel]');
            ylabel('# Objects');
            title([num2str(i, '%i') num2str(j, '%i') num2str(k, '%i')]); 
            display([num2str(i) num2str(j) num2str(k)]);
            pause(.2);
        end
    end
end
end

