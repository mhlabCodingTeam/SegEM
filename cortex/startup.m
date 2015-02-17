% set Matlab path for cortex
addpath(genpath([codeDirectory filesep 'cortex']));
addpath(genpath([codeDirectory filesep 'auxiliaryMethods']));
addpath(genpath([codeDirectory filesep 'volumeReconstruction']));

% open relevant scripts for cortex
cortexSubfolder = [codeDirectory filesep 'cortex' filesep];
open([cortexSubfolder 'CNN' filesep 'cnnStart.m']);
open([cortexSubfolder 'CNN' filesep 'evolution' filesep 'cnnParameterSelection.m']);
open([cortexSubfolder 'segmentation' filesep 'mainSeg.m']);
open([cortexSubfolder 'segmentation' filesep 'visualization' filesep 'visSeg.m']);
open([cortexSubfolder 'wholeDataset' filesep 'wholeDatasetFwdPass.m']);
open([codeDirectory filesep 'volumeReconstruction' filesep 'skeletonsToContacts.m']);
clear cortexSubfolder;

% create parameter settings for cortex for easier access to data/storage
% locations etc.:
[p, pT] = setParameterSettings(dataDirectory, outputDirectory);