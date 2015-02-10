%% Set enviroment & parameters
clc; %clear all;
%date = datestr(clock, 30);
cd('/home/mberning/code/');
addpath('auxiliary');
addpath('auxiliary/skeletons/');
addpath('segmentation');

% Folders
param.dataFolder =  '/data/minicube/';
param.affSubfolder = ['affinityMaps' filesep];
param.outputSubfolder = [date filesep];
param.figureSubfolder = [param.outputSubfolder 'figures' filesep];

% Set parameter for scan
param.r = 0:1;
param.algo{1} = 'v1';
% param.pR{1,1} = {0.05:0.05:0.4 0:50:200};
% param.pR{2,1} = {0.05:0.05:0.4 0:50:200};
% param.pR{3,1} = {0.05:0.05:0.4 0:50:200};
param.pR{1,1} = {[] []};
param.pR{2,1} = {[] []};
param.pR{3,1} = {[] []};
param.algo{2} = 'v2';
param.pR{1,2} = {-0.2:0.01:0 0:20:60};
param.pR{2,2} = {0.25:0.01:0.45 0:20:60};
param.pR{3,2} = {-0.45:0.01:-0.25 0:20:60};

% Set parameter for evaluation
param.nodeThres = 1;

% Set parameter for optional visualization
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

%%  Choose affinity maps for training and test data
paramTest = param;
param.affMaps(2) = [];
paramTest.affMaps(1) = [];

%% Transform to local coordiantes
param.skeletons = 'ssdf.221.nml';
skel = readKnossosNml([param.dataFolder param.skeletons]);
skel = switchToLocalCoords( skel, [13 14 17] );
skel = correctSkeletonsToBBox(skel);
writeKnossosNml([param.dataFolder param.skeletons 'local'], skel);
param.skeletons = [param.skeletons 'local'];
skel = readKnossosNml([param.dataFolder param.skeletons]);
param.skel = skel;
param.totalPathLength = getPathLength(skel);

%% Transform to local coordiantes
paramTest.skeletons = 'mini1eClean.nml';
skel = readKnossosNml([paramTest.dataFolder paramTest.skeletons]);
skel = switchToLocalCoords( skel, [24 4 20] );
skel = correctSkeletonsToBBox(skel);
writeKnossosNml([paramTest.dataFolder paramTest.skeletons 'local'], skel);
paramTest.skeletons = [paramTest.skeletons 'local'];
skel = readKnossosNml([paramTest.dataFolder paramTest.skeletons]);
paramTest.skel = skel;
paramTest.totalPathLength = getPathLength(skel);

%% Write skeleton video for control of 'training data'
load([param.dataFolder param.affSubfolder param.affMaps(1).name '.mat'], 'raw');
raw = raw(1:end,1:end,1:end);
% makeSkeletonMovies(param, raw);

%% Main cell for parameter tuning
matlabpool 3;
% Perform morphological reconstruction (also complements; for r=0 just imcomplement is performed)
morphR(param);
% Start the parameter scan (will automatically save & overwrite save to outputSubfolder)
scanParameterSegmentation(param);
% Analysis
evalParameterSegmentation(param);
% Overview of performance of different segmentations
visualizeOverview_2(param);
matlabpool close;

%% Main cell for parameter tuning
matlabpool 3;
% Perform morphological reconstruction (also complements; for r=0 just imcomplement is performed)
morphR(paramTest);
% Start the parameter scan (will automatically save & overwrite save to outputSubfolder)
scanParameterSegmentation(paramTest);
% Analysis
evalParameterSegmentation(paramTest);
% Overview of performance of different segmentations
visualizeOverview_2(paramTest);
matlabpool close;

%% Training & Test Plot For Paper
visualizeOverview_4(param,paramTest);

%% update 04.02 
param.skeletons = [param.skeletons '2'];
param.skel = parseNml([param.dataFolder param.skeletons]);
param.totalPathLength = getPathLength(param.skel);
paramTest.skeletons = [paramTest.skeletons '2'];
paramTest.skel = parseNml([paramTest.dataFolder paramTest.skeletons]);
paramTest.totalPathLength = getPathLength(paramTest.skel);
save('/data/screen2_cortex.mat');
visualizeOverview_4(param,paramTest)

%% update 11.02
param.pR = [];
param.pR{1,1} = {[] []};
param.pR{1,2} = {0.2:0.01:0.5 [0:20:60 100 150]};
paramTest.pR = [];
paramTest.pR{1,1} = {[] []};
paramTest.pR{1,2} = {0.2:0.01:0.5 [0:20:60 100 150]};
 
%% Redo parameter search
% matlabpool 3;
% Perform morphological reconstruction (also complements; for r=0 just imcomplement is performed)
% morphR(param);
% Start the parameter scan (will automatically save & overwrite save to outputSubfolder)
scanParameterSegmentation(param);
% Analysis
evalParameterSegmentation(param);
% Overview of performance of different segmentations
visualizeOverview_2(param);

% Perform morphological reconstruction (also complements; for r=0 just imcomplement is performed)
morphR(paramTest);
% Start the parameter scan (will automatically save & overwrite save to outputSubfolder)
scanParameterSegmentation(paramTest);
% Analysis
evalParameterSegmentation(paramTest);
% Overview of performance of different segmentations
visualizeOverview_2(paramTest);
matlabpool close;

%% update 25.02
load('/data/screen2_retina.mat');
param.affMaps = dir([param.dataFolder param.affSubfolder '*.mat']);
paramTest.affMaps = dir([param.dataFolder param.affSubfolder '*.mat']);
param.affMaps(1) = [];
paramTest.affMaps(2) = [];
param.affMaps(1).name(end-3:end) = [];
paramTest.affMaps(1).name(end-3:end) = [];

