% set Matlab path for cortex
addpath(genpath([codeDirectory filesep 'retina']));
addpath(genpath([codeDirectory filesep 'auxiliaryMethods']));
addpath(genpath([codeDirectory filesep 'volumeReconstruction']));

% open relevant scripts
open('CNN/main_legacy.m');
open('segmentation/mainSeg_legacy.m');
open('segmentation/visualization/visSeg_legacy.m');
open('../volumeReconstruction/skeletonsToContacts_legacy.m');