%% Example usage of parameter grid search for segmentation parameters
% this requires first 'cell' of wholeDatasetFwdPass.m has been executed
% before (performs classification on densly skeletonized regions)

if ~exist([outputDirectory filesep 'segOptCortex' filesep], 'dir')
    mkdir([outputDirectory filesep 'segOptCortex' filesep]);
end

% copy dense skeletonizations to working directory
copyfile([dataDirectory filesep 'supplement' filesep 'extracted' filesep 'cortex_test.nml'], ...
    [outputDirectory filesep 'segOptCortex' filesep]);
copyfile([dataDirectory filesep 'supplement' filesep 'extracted' filesep 'cortex_training.nml'], ...
    [outputDirectory filesep 'segOptCortex' filesep]);

% Parameter settings

% Folder structure 
param.dataFolder = [outputDirectory filesep 'segOptCortex' filesep];
param.affSubfolder = ['aff' filesep];
param.outputSubfolder = ['output' filesep];
if ~exist([param.dataFolder param.outputSubfolder], 'dir');
    mkdir([param.dataFolder param.outputSubfolder])
end
param.figureSubfolder = [param.outputSubfolder 'figures' filesep];
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
param.r = 0; % Radii for Morphological Reconstruction
param.algo(1).fun = @(seg,pars) watershedSeg_v1_cortex(seg, pars(:));
%param.algo(1).par = {0.02:0.02:0.7 0:50:100};
param.algo(1).par = {0.2:0.1:0.8 [10 50]};
param.algo(2).fun = @(seg,pars) watershedSeg_v2_cortex(seg, pars(:));
param.algo(2).par = {0.2:0.1:0.8 [10 50]};

% Set parameter for evaluation
param.nodeThres = 1; % Number of nodes within object that count as connection

% Set parameter for visualization of results
param.makeSegMovies = true;
param.makeErrorMovies = true;
param.plotObjSizeHist = true;
param.objSizeCutoff = 100000;
param.plotObjChains = true;
param.plotSynRate = true;
param.makeErrorStacks = true;

%  Choose affinity maps for training and test data
paramTest = param;
param.affMaps(2) = []; % only region 1 for training regions
paramTest.affMaps(1) = []; %  region 2 for testing

%% Read skeleton for training (and do preprocessing, e.g. create local version clipped to bbox)
param.skeletons = 'cortex_training.nml'; % Skeleton file for segmentation evaluation
param.skel = parseNml([param.dataFolder param.skeletons]);
param.skel = removeEmptySkeletons(param.skel);
% Switch to coordinates of small subcube (offset has to be inital voxel of
% bbox - [1 1 1] due to one index of matlab (another [1 1 1] if tracing was done in oxalis)
param.skel = switchToLocalCoords_v2(param.skel, [4097 4481 2250] - [1 1 1]);
% Remove all nodes outside small subcube
param.skel = correctSkeletonsToBBox_v2(param.skel, [640 768 201]);
% Calculate total path length of the skeleton within this box
param.totalPathLength = getPathLength(param.skel);
% Write skeleton video for control of training data
load([param.dataFolder param.affSubfolder param.affMaps(1).name '.mat'], 'raw');
makeSkeletonMovies(param, normalizeStack(raw));
% Write local version of skeleton
writeNml([param.dataFolder param.skeletons 'local'], param.skel);

%% Read skeleton for testing (and do preprocessing, e.g. create local version clipped to bbox)
paramTest.skeletons = 'cortex_test.nml'; % Skeleton file for segmentation evaluation
paramTest.skel = parseNml([paramTest.dataFolder paramTest.skeletons]);
paramTest.skel = removeEmptySkeletons(paramTest.skel);
% Switch to coordinates of small subcube (offset has to be inital voxel of
% bbox - [1 1 1] due to one index of matlab (another [1 1 1] if tracing was done in oxalis)
paramTest.skel = switchToLocalCoords_v2(paramTest.skel, [1417 4739 890] - [1 1 1]);
% Remove all nodes outside small subcube
paramTest.skel = correctSkeletonsToBBox_v2(paramTest.skel, [300 300 300]);
% Calculate total path length of the skeleton within this box
paramTest.totalPathLength = getPathLength(paramTest.skel);
% Write skeleton video for control of testing data
load([paramTest.dataFolder paramTest.affSubfolder paramTest.affMaps(1).name '.mat'], 'raw');
makeSkeletonMovies(paramTest, normalizeStack(raw));
% Write local version of skeleton
writeNml([paramTest.dataFolder paramTest.skeletons 'local'], paramTest.skel);

%% Save parameter file to disk
save([param.dataFolder param.outputSubfolder 'parameter.mat'], 'param', 'paramTest');

%% Main cell for parameter tuning training region
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
visualizeOverview_3(param);

%% Main cell for testing later (otherwise same as above)
pp = parpool(jobManagerName);
for map=1:length(paramTest.affMaps)
    tic
    for r=1:length(paramTest.r)
        disp(['Started morph, scan and eval for map ' num2str((map-1).*length(paramTest.r)+r) '/' num2str(length(paramTest.affMaps).*length(paramTest.r))]);
        morphScanAndEval(paramTest,paramTest.affMaps(map).name,r);
    end
    toc
end
delete(pp);

%% Equalize inter-node-distance in skeletons for better/fairer comparison
skel{1} = param.skel;
skel{2} = paramTest.skel;
skel = equalizeSkeletons(skel);
% save equalized skeletons and output statistics to text file
writeNml([param.dataFolder filesep param.skeletons 'localsubsampled'], skel{1});
writeNml([paramTest.dataFolder filesep paramTest.skeletons 'localsubsampled'], skel{2});
skeletonStatistics([paramTest.dataFolder filesep]);

%% Visualize training vs. test set comparison on subsampled skeletons
param.skel = skel{1};
paramTest.skel = skel{2};
visualizeOverview_6cortex(param,paramTest);
