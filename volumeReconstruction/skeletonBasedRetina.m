%% Skeleton based volume reconstruction
% This file shows how to use segmentation of whole dataset 
% for volume reconstruction and contact detection based on skeletons

%%
% Set output directory in setParameterSettings to datasets subfolder for
% using segmentation supplied segmentation (for testing without having to
% rerun classification and segmentation
seg.root = [dataDirectory filesep 'datasets' filesep 'ek0563' filesep 'seg' filesep];
seg.prefix = '100527_k0563_seg';
% Start isosurface visualization of volume reconstruction
galleryRetinaStart(dataDirectory, outputDirectory, seg);

%%
contactDetectionRetinaStart(dataDirectory, outputDirectory, seg);
