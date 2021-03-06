%% Example usage of parameter grid search for segmentation parameters
% this requires first 'cell' of wholeDatasetFwdPass.m has been executed
% before (performs classification on densly skeletonized regions)

% Folder structure 
param.dataFolder = [outputDirectory filesep 'segOptCortex5' filesep];
% Place a arbitrarly named .mat file in this folder containing the
% classification of the region(s) you want to look at of size of the
% respective dense skeleton annotations
param.affSubfolder = ['aff' filesep];
% Output and figure folders for saving output
param.outputSubfolder = ['output' filesep];
param.figureSubfolder = [param.outputSubfolder 'figures' filesep];

if ~exist(param.dataFolder, 'dir')
    mkdir(param.dataFolder);
end
if ~exist([param.dataFolder param.affSubfolder], 'dir');
    mkdir([param.dataFolder param.affSubfolder])
end
if ~exist([param.dataFolder param.outputSubfolder], 'dir');
    mkdir([param.dataFolder param.outputSubfolder])
end
if ~exist([param.dataFolder param.figureSubfolder], 'dir');
    mkdir([param.dataFolder param.figureSubfolder])
end

% Find all affinity maps from aff subfolder
param.affMaps = dir([param.dataFolder param.affSubfolder filesep '*.mat']);
for i=1:length(param.affMaps)
    param.affMaps(i).name(end-3:end) = [];
end
clear i;

% Set parameter for scan
param.r = [0 1 2]; % Radii for Morphological Reconstruction
param.algo(1).fun = @(seg,pars) watershedSeg_v1_cortex(seg, pars(:));
param.algo(1).par = {0.005:0.005:0.1 0:50:200};
param.algo(2).fun = @(seg,pars) watershedSeg_v2_cortex(seg, pars(:));
param.algo(2).par = {1:0.05:1.7 0:50:200};

% Set parameter for evaluation
param.nodeThres = 1; % Number of nodes within object that count as connection

% Set parameter for visualization of results
param.makeSegMovies = true;
param.makeErrorMovies = true;
param.plotObjSizeHist = true;
param.objSizeCutoff = 100000;
param.plotObjChains = true;

%  Choose affinity maps for training and test data
paramTest = param;
param.affMaps(2) = []; % only region 1 for training regions
paramTest.affMaps(1) = []; %  region 2 for testing

% copy dense skeletonizations to working directory
% see [SegEM]/cortex/segmentation/skeletonPreperations for preprocessing on
% skeletons (transform to local coordinates, limit to bounding box, remove
% glia and other non-wanted annotations)
copyfile([outputDirectory filesep 'cortex_test_local_subsampled.nml'], ...
    [outputDirectory filesep 'segOptCortex' filesep]);
copyfile([outputDirectory filesep 'cortex_training_local_subsampled.nml'], ...
    [outputDirectory filesep 'segOptCortex' filesep]);

% Load skeletons for split-merger evaluation
param.skel = parseNml([outputDirectory filesep 'segOptCortex' filesep 'cortex_training_local_subsampled.nml']);
param.totalPathLength = getPathLength(param.skel);
paramTest.skel = parseNml([outputDirectory filesep 'segOptCortex' filesep 'cortex_test_local_subsampled.nml']);
paramTest.totalPathLength = getPathLength(paramTest.skel);

%% Save parameter file to disk
save([param.dataFolder param.outputSubfolder 'parameter.mat'], 'param', 'paramTest');

%% Main cell for parameter tuning training region, takes ~1.5h w. 4 workers on laptop
% This will do morphological reconstruction & watershed segmenation and
% calculate skeleton-based split-merger metric with parameters set above
% Currently paralell over first parameter of segmentation function, usually
% varied most? generalize?
pp = parpool(jobManagerName);
for map=1:length(param.affMaps)
    tic
    for r=1:length(param.r)
        disp(['Started morph, scan and eval for map ' num2str((map-1).*length(param.r)+r) '/' num2str(length(param.affMaps).*length(param.r))]);
        morphScanAndEval(param,param.affMaps(map).name,r);
    end
    toc
end
delete(pp);

%% Overview of performance of different segmentations (training region only)
visualizeOverview(param);

%% Main cell for testing later (otherwise same as above)
pp = parpool(jobManagerName);
for map=1:length(paramTest.affMaps)
    tic
    for r=1:length(paramTest.r)
        disp(['Started morph, scan and eval for map ' num2str((map-1).*length(paramTest.r)+r) '/' num2str(length(paramTest.affMaps).*length(paramTest.r))]);
        morphScanAndEval(paramTest,paramTest.affMaps(map).name,r, true);
    end
    toc
end
delete(pp);

%% Visualize training vs. test set comparison on subsampled skeletons
visualizeOverviewComparison(param,paramTest);

%%
visualizeOverviewWithThreeLinesAndZeroHits( param,paramTest )

%%
visualizeOverviewNodeSizeControl(param, paramTest);

%%
visualizeOverviewNew( param,paramTest );
