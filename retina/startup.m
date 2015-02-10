% load data
load('../folders.mat');

% set Matlab path for retina
addpath(genpathGit(pwd));
addpath(genpathGit('../auxiliaryMethods/'));
addpath(genpathGit('../volumeReconstruction/'));

% open relevant scripts
open('CNN/main.m');
open('segmentation/mainSeg.m');
open('segmentation/visualization/visSeg.m');
open('segmentation/wholeDataset/ekSegmentationToJm.m');
open('../volumeReconstruction/galleryRetinaStart.m');
open('../volumeReconstruction/contactDetectionRetinaStart.m');
