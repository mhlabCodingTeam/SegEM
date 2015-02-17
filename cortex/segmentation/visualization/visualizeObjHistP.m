function visualizeObjHistP( param, general, segmentation, par1, par2)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

figure('Visible', 'off');
sizeObj = hist(single(segmentation(:)),1:general.maxNrObjects);
sizeObj(sizeObj > param.objSizeCutoff) = param.objSizeCutoff;
hist(single(sizeObj), 250:500:(param.objSizeCutoff - 250));
xlabel('Object Size [voxel]');
ylabel('# Objects');
saveas(gcf, [param.outputFolder 'objHist.pdf']);
close all;

end

