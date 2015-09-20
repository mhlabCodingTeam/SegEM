%% Set enviroment & parameters
clc;
param.dataFolder =  [outputDirectory 'segOptRetina' filesep];
param.affSubfolder = ['affinityMaps' filesep];
param.outputSubfolder = ['seg' date filesep];
param.figureSubfolder = [param.outputSubfolder 'figures' filesep];

% Set parameter for scan
param.r = 0:1; % Radii for Morphological Reconstruction
param.algo{1} = 'v1'; % Hmin Segmentation (not used for now)
param.pR{1,1} = {[] []}; % Depth minima removal & marker volumes cutoff (should be increasing values for 2nd param)
% param.pR{2,1} = {[] []};
% param.pR{3,1} = {[] []};
% param.pR{4,1} = {[] []};
% param.pR{5,1} = {[] []};
param.algo{2} = 'v2'; % Threshold Segmentation
param.pR{1,2} = {0.2:0.01:0.5 [0:20:60 100 150]}; % Threshold & marker volumes cutoff (should be increasing values for 2nd param)
% param.pR{2,2} = {[] []};
% param.pR{3,2} = {[] []};
% param.pR{4,2} = {-0.2:0.02:-0.1 0:20:100};
% param.pR{5,2} = {0.25:0.02:0.35 0:20:100};
% Set parameter for evaluation
param.nodeThres = 1; % Number of nodes within object that count as connection
param.skeletons = 'retina_test_local_subsampled.nml'; % Skeleton file for segmentation evaluation
param.cmSource = 'segmentation/autoKLEE_colormap.mat';
param.makeSegMovies = true;
param.makeErrorMovies = true;
param.plotObjSizeHist = true;
param.objSizeCutoff = 100000; % choose upper xlim bound histogram
param.plotObjChains = true;
param.plotSynRate = true;
param.makeErrorStacks = true;

% Some dependent parameter calculations (usually no change needed)
param.affMaps = dir([param.dataFolder param.affSubfolder '*.mat']);
for i=1:length(param.affMaps)
    param.affMaps(i).name(end-3:end) = [];
end
clear i;

% Account for weird KNOSSOS rescaling (due to misspecification of scale parameter in knossos.conf)
% Usually not necessary, done for first minicube
% skel = readKnossosNml([param.dataFolder param.skeletons]);
% toDelete = []; % Collect empty skeletons
% for l=1:size(skel,2)
%     if isfield(skel{l}, 'nodesNumDataAll')
%         skel{l}.nodesNumDataAll(:,3:5) = (skel{l}.nodesNumDataAll(:,3:5)-1)/100 + repmat(([1 1 1]),size(skel{l}.nodesNumDataAll,1),1);
%     else
%         toDelete = [toDelete l];
%     end
% end
% skel(toDelete) = [];
% skel{1}.parameters.scale.x = num2str(12);
% skel{1}.parameters.scale.y = num2str(12);
% skel{1}.parameters.scale.z = num2str(25);
% writeKnossosNml([param.dataFolder param.skeletons 'rescaled'], skel);

%% Transform to local coordiantes & correct to BBox (careful with nodes & nodesNumDataAll)
skel = readKnossosNml([param.dataFolder param.skeletons]);
writeKnossosNml([param.dataFolder param.skeletons], skel);
skel = switchToLocalCoords( skel, [13 14 17] );
skel = correctSkeletonsToBBox(skel);
writeKnossosNml([param.dataFolder param.skeletons 'local'], skel);
param.skeletons = [param.skeletons 'local'];
skel = readKnossosNml([param.dataFolder param.skeletons]);
param.skel = skel;
param.totalPathLength = getPathLength(skel);

%% Save parameter file to disk
if ~exist([param.dataFolder param.outputSubfolder], 'dir')
    mkdir([param.dataFolder param.outputSubfolder]);
end
save([param.dataFolder param.outputSubfolder 'parameter.mat'], 'param');

%% Load old parameter file from disk
dateToLoad = '02-Nov-2012';
addpath('auxiliary');
addpath('segmentation');
subfolder = ['seg' dateToLoad filesep];
if strcmp(computer,'PCWIN64')
    dataFolder =  'C:\data\minicube\';
else
    dataFolder =  '/data/e_k0563/minicube/';
end
load([dataFolder subfolder 'parameter.mat']);

%% Main cell for parameter tuning
parpool(jobManagerName);
% Perform morphological reconstruction (also complements; for r=0 just imcomplement is performed)
morphR(param);
% Start the parameter scan (will automatically save & overwrite save to outputSubfolder)
scanParameterSegmentation(param);
% Analysis
evalParameterSegmentation(param);
% Overview of performance of different segmentations
visualizeOverview_2(param);
delete(pp);
