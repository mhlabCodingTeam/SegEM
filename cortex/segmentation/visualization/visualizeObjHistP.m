function visualizeObjHistP( param, general, segmentation, par1, par2)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

figure('Visible', 'off');
sizeObj = hist(single(segmentation{par1, par2}(:)),1:general(par1,par2).maxNrObjects);
sizeObj(sizeObj > param.objSizeCutoff) = param.objSizeCutoff;
hist(single(sizeObj), 250:500:(param.objSizeCutoff - 250));
xlabel('Object Size [voxel]');
ylabel('# Objects');
saveas(gcf, [param.dataFolder param.figureSubfolder param.subfolder '/objHist.pdf']);
close all;

end

