%% Set enviroment & parameters
clear all; clc;
%mex CFLAGS="\$CFLAGS -U FORTIFY_SOURCE -std=c99" -largeArrayDims /home/mberning/code/manuelMisc/watershit_3D.c;
addpath('/home/mberning/code/auxiliaryMethods/');
addpath('/home/mberning/code/manuelMisc/');
param.dataFolder =  '/data/e_k0563/minicube/';
param.affSubfolder = 'affinityMaps/';
param.outputSubfolder = 'segmentations2/';
param.figureSubfolder = 'figures2/';

param.mapsChooser = 1:5; % Choose which maps (=CNNs)
param.rChooser = 1:3; % Choose size of  morphological reconstructions 
param.algoChooser = 1:2; % Choose which algorithms to use (see 

% Set parameter for scan
param.r = 0:2; % Radii for Morphological Reconstruction
param.algo{1} = 'v1'; % Hmin Segmentation
param.pR{1,1} = {[] []}; % Depth minima removal & marker volumes cutoff (should be increasing values for 2nd param)
param.pR{2,1} = {[] []};
param.pR{3,1} = {[] []};
param.pR{4,1} = {[] []};
param.pR{5,1} = {[] []};
param.algo{2} = 'v2'; % Threshold Segmentation
param.pR{1,2} = {[] []}; % Threshold & marker volumes cutoff (should be increasing values for 2nd param)
param.pR{2,2} = {-0.4:0.025:-0.2 0:50:400};
param.pR{3,2} = {[]  []};
param.pR{4,2} = {-0.2:0.025:0 0:50:400};
param.pR{5,2} = {0.2:0.025:0.4 0:50:400};
% Set parameter for evaluation
param.nodeThres = 1; % Number of nodes within object that count as connection
param.skeletons = 'ssdf.177.nml'; % Skeleton file for segmentation evaluation
param.cmSource = '/home/mberning/code/manuelMisc/autoKLEE_colormap.mat';
param.makeSegMovies = true;
param.makeErrorMovies = true;
param.plotObjSizeHist = true;
param.objSizeCutoff = 100000; % choose upper xlim bound histogram
param.plotObjChains = true;
param.plotSynRate = true;

% Some dependent parameter calculations (usually no change needed)
param.affMaps = dir([param.dataFolder param.affSubfolder '*.mat']);
for i=1:length(param.affMaps)
    param.affMaps(i).name(end-3:end) = [];
end
clear i;
save([param.dataFolder param.outputSubfolder 'parameter.mat'], 'param');

%% Perform morphological reconstruction (also complements; for r=0 just imcomplement is performed)
morphR(param);

%% Main cell for parameter tuning
matlabpool 5;
% Start the parameter scan (will automatically save & overwrite save to outputSubfolder)
scanParameterSegmentation(param, 1);
% Analysis
param = evalParameterSegmentation(param, 1);
% Overview of performance of different segmentations
visualizeOverview(param, 1);
% 
matlabpool close
