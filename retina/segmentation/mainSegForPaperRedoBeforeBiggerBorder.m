%% Set enviroment & parameters
clc;
date = datestr(clock, 30);
addpath('auxiliary');
addpath('auxiliary/skeletons/');
addpath('segmentation');

% Folders
param.dataFolder =  '/data/minicube2/';
param.affSubfolder = ['affinityMaps' filesep];
param.outputSubfolder = [date filesep];
param.figureSubfolder = [param.outputSubfolder 'figures' filesep];

% Set parameter for scan
param.r = 0:2;
param.algo{1} = 'v1';
param.pR{1,1} = {0:0.1:0.6 0:20:80};
param.algo{2} = 'v2';
param.pR{1,2} = {-0.3:0.1:0.5 0:20:80};

% Set parameter for evaluation
param.nodeThres = 1;
param.skeletons = 'ssdf.221.nmllocal';
param.skel = readKnossosNml([param.dataFolder param.skeletons]);
param.totalPathLength = getPathLength(param.skel);

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

%% Main cell for parameter tuning
matlabpool 5;
% Perform morphological reconstruction (also complements; for r=0 just imcomplement is performed)
morphR(param);
% Start the parameter scan (will automatically save & overwrite save to outputSubfolder)
scanParameterSegmentation(param);
% Analysis
evalParameterSegmentation(param);
% Overview of performance of different segmentations
visualizeOverview_2(param);
matlabpool close;

%%
set(findall(gcf,'-property','FontSize'),'FontSize',14)
