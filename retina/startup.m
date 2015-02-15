% set Matlab path for cortex
addpath(genpath([codeDirectory filesep 'retina']));
addpath(genpath([codeDirectory filesep 'auxiliaryMethods']));
addpath(genpath([codeDirectory filesep 'volumeReconstruction']));

% open relevant scripts
open('CNN/main.m');
open('segmentation/mainSeg.m');
open('segmentation/visualization/visSeg.m');
open('../volumeReconstruction/skeletonBasedRetina.m');