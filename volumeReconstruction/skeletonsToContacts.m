%% Skeleton based volume reconstruction
% This file shows how to use segmentation of whole dataset 
% for volume reconstruction and contact detection

%%
% Set output directory in setParameterSettings to datasets subfolder for
% using segmentation supplied segmentation (for testing without having to
% rerun classification and segmentation
providedSegmentationFolder = [dataDirectory filesep 'datasets' filesep '2012-09-28_ex145_07x2_corrected' filesep];
[pBig, ~] = setParameterSettingsBig(dataDirectory, providedSegmentationFolder, '20141007T094904');
% Start isosurface visualization of volume reconstruction
galleryCortexStart(pBig, dataDirectory, outputDirectory)

%%
contactDetectionCortexStart(pBig, dataDirectory, outputDirectory)
