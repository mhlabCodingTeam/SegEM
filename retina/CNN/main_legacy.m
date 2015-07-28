%% Script for demonstrating use of CNN training on affinity maps (and retina training data)
% This version of the code (retina) is no longer developed and mainly here for
% documentation

%% Load raw and trace data (and exclude ones with traicng errors or large processes)
pathToRawData = [dataDirectory filesep 'onlineMaterial' filesep 'extracted' filesep 'raw' filesep];
pathToTracingData = [dataDirectory filesep 'onlineMaterial' filesep 'extracted' filesep 'tracing' filesep];
[dataRaw, dataTrace] = getKleeStackList(pathToRawData,pathToTracingData);
% Exclude 186 %% ribbon ID as mentioned in filename, does NOT match index here
dataRaw(174) = [];
dataTrace(174) = [];
% Exclude 183
dataRaw(171) = [];
dataTrace(171) = [];
% Exclude 163
dataRaw(153) = [];
dataTrace(153) = [];
% Exclude 159
dataRaw(149) = [];
dataTrace(149) = [];
% Exclude 130, 131 und 132
dataRaw(122:124) = [];
dataTrace(122:124) = [];
% Exclude 106
dataRaw(99) = [];
dataTrace(99) = [];
% Exclude 64
dataRaw(62) = [];
dataTrace(62) = [];
% Exclude 26
dataRaw(26) = [];
dataTrace(26) = [];
% Exclude 6
dataRaw(6) = [];
dataTrace(6) = [];

%% Visualize
stackNr = 1;
load(dataRaw{stackNr});
load(dataTrace{stackNr});
makeSegMovie(kl_stack, kl_roi, [outputDirectory filesep 'stackVideo.avi']);
makeIsosurfaceView(kl_stack, kl_roi, [outputDirectory filesep 'stackView.png']);

%% Example: Initialize CNNs and start on cluster
if ~exist('dataRaw', 'var');
    error('Load data first!');
end

nrJobs = 4;
cnet = cell(nrJobs,1);
% Create CNNs with standard parameter values
for i=1:nrJobs
    % Create instance of cnn class
    cnet{i} = cnn();
    cnet{i}.numHiddenLayer = 4;
    cnet{i}.numFeature = 10;
    cnet{i}.filterSize = [8 8 4];
    cnet{i}.outputSize = [12 12 6];
    cnet{i}.numLabels = 3;
    cnet{i}.masking = @xyzMaskIso;
    cnet{i}.isoBorder = 2;
    % Create instance of train class for each CNN
    cnet{i}.run = train();
    cnet{i}.run.maxIter = 1e6;
    cnet{i}.run.maxIterMini = 500;
    cnet{i}.run.GPU = true;
    cnet{i}.run.local = false;
    cnet{i}.run.constant_stepsize = false;
    cnet{i}.run = cnet{i}.run.setEtaWLinear(1,1e-5);
    cnet{i}.run = cnet{i}.run.setEtaBLinear(1e-2,1e-7);
    cnet{i}.run.wghtTyp = @double;
    % Decide whether CNN can be run on GPU over jobmanager
    % If so set actctType = @gdouble (Jacket Accelereyes) or @gpuArray for 
    % MATLAB, one will also probably need to change @cnn/trainGradient to work with
    % cluster infrastructure (e.g. how many GPU per node etc.)
    cnet{i}.run.actvtTyp = @double;
    cnet{i}.run.saveTyp = @double;
    cnet{i}.run.debug = true;
end

% Vary one paramter for each instance of cnet
cnet{1}.run = cnet{1}.run.setEtaWLinear(cnet{1}.run.wStart*1e1,cnet{1}.run.wStart*1e-4);
cnet{2}.run = cnet{2}.run.setEtaWLinear(cnet{2}.run.wStart*1e-1,cnet{2}.run.wStart*1e-6);
cnet{3}.run = cnet{3}.run.setEtaWLinear(cnet{3}.run.wStart*1e-2,cnet{3}.run.wStart*1e-7);
cnet{4}.run = cnet{3}.run.setEtaWLinear(cnet{4}.run.wStart*1e2,cnet{4}.run.wStart*1e-3);

% Calculate dependent parameters of CNNs
for i=1:nrJobs
    cnet{i}.run.inputSize = (cnet{i}.numHiddenLayer + 1) * (cnet{i}.filterSize - 1) + cnet{i}.outputSize;
    cnet{i} = cnet{i}.init;
end

% Train CNNs on cluster
for i=1:nrJobs
    submitJob(cnet{i}, dataRaw, dataTrace, outputDirectory);
end

%% Kill all jobs on cluster (e.g. if visualization (s. below) shows bad results or errors occured)
killAllJobs(2, 0);

%% Kill subset of jobs on cluster (same for a subset of CNN's identified by 6 digit number generated at start)
randNumber = {814723 097540 157613 970592 957166 485375 800280};
killJob(randNumber);

%% Kill finished jobs
jm = findResource('scheduler', 'type', 'jobmanager', 'LookupURL', 'fermat01');
job = findJob(jm(1), 'Username', 'someUser', 'state', 'finished');
destroy(job);

%% Evaluate all currently running networks
load /path/to/some/directory/fermatResults/activeJobs.mat;
sizeMovAvg = 5000;
display('Plotting net activities:');
plotNetActivities(jobs);
display('Plot error with sliding window:');
plotError(jobs, sizeMovAvg);
display('Plot error binned:');
plotErrorBinned(jobs);
display('Plot error resorted:');
plotErrorResorted(jobs);

%% Select & load a certain CNN after consulting plots above (semiautomated selection)
dateString = '14-May-2012';
net = 957506;
cnetContinue = loadSingleCNN(['/path/to/some/directory/fermatResults/trainCNN/' dateString '/net' num2str(net, '%6.6u') '/']);

%% Restart CNN loaded above with varied parameters
nrJobs = 4;
for i=1:nrJobs
    cnet{i} = cnetContinue;
end

% Vary paramter for each instance of cnet
cnet{1}.run = cnet{1}.run.setEtaBLinear(1e1,1e-4);
cnet{2}.run = cnet{2}.run.setEtaBLinear(1e1,1e-4);
cnet{3}.run = cnet{3}.run.setEtaBLinear(1e1,1e-4);
cnet{4}.run = cnet{4}.run.setEtaBLinear(1e0,1e-5);
cnet{1}.run = cnet{1}.run.setEtaWLinear(1e-3,1e-8);
cnet{2}.run = cnet{2}.run.setEtaWLinear(1e-4,1e-9);
cnet{3}.run = cnet{3}.run.setEtaWLinear(1e-5,1e-10);
cnet{4}.run = cnet{4}.run.setEtaWLinear(1e-3,1e-8);

for i=1:nrJobs
    submitJob(cnet{i}, dataRaw, dataTrace);
end

%% Evaluate networks not currently running (adjust nets & date value)
dateString = '02-Apr-2012';
list = dir(['/path/to/some/directory/fermatResults/' dateString '/' 'net*']);

for i=1:length(list)
    jobs.(list(i).name).date = dateString;
    jobs.(list(i).name).rand = list(i).name(4:end);
end

sizeMovAvg = 50000;
plotNetActivities(jobs);
plotError(jobs, sizeMovAvg);

%% Make a big fwdPass through the network
dateString = '14-Jul-2012';
net = 694915;
addpath('/path/to/some/directory/code/CNN/');
pathRaw.root = '/path/to/some/directory/e_k0563/k0563_mag1/';
pathRaw.prefix = '100527_k0563_mag1';
pathResult.root = ['/path/to/some/directory/fermatResults/fwdPass/' date '/'];
pathResult.prefix = '100527_k0563_mag1';
pathResult.folders = {'x' 'y' 'z'};
datasetSize = [4608 5504 5760];

cnet = loadSingleCNN(['/path/to/some/directory/fermatResults/trainCNN/' dateString '/net' num2str(net, '%6.6u') '/']);
cnet.run.actvtTyp = @single;
bigFwdPass(cnet, pathRaw, pathResult, datasetSize);

%% For some reviewer, calculate errors for figure 4 (pixel error on cortex test region for retina test set)

% Load one cortex test stack
load('/home/mberning/fsHest/Data/berningm/20150205paper1submission/onlineMaterial/extracted/testSet/targetKLEE/130.mat');
% Load retina CNN
%load('/home/mberning/fsHest/Data/berningm/20150205paper1submission/supplement/extracted/retina - CNN32.mat', 'cnet');
% Or load cortex CNN (need to comment uncomment some other lines below as
% well if siwtching back to retina )
load('/home/mberning/fsHest/Data/berningm/20150205paper1submission/supplement/extracted/cortex - CNN20130516T204040_8_3.mat', 'cnet');

% Specify activity type to be single rather than gsingle (could also use
% gpuarray, gsingle still old jacket approach)
%cnet.run.actvtTyp = @single;
cnet.run.actvtClass = @single;
% Normalize stack
rawBig = normalizeStack(single(rawBig));
% Run CNN forwardPass
class = cnet.fwdPass3D(rawBig);
% Drop result from earlier layers
class(1:5,:) = [];
% Cut out valid region in 3 affinity maps (last layer of output)
% f = @(x)x(33:end-33,33:end-33,18:end-18);
% class = cellfun(f,class(1:3), 'UniformOutput', false);
f = @(x)x(26:end-25,26:end-25,16:end-15);
class = cellfun(f,class(1), 'UniformOutput', false);
% Average 3 affinity maps generated as output
% aff = cat(4,class{:});
% aff = mean(aff,4);
% Compute squared pixel error
g = @(x,y)sum(reshape((x-y).^2/2, [numel(x) 1 1]))/1e6;
% error = g(aff, single(target));
error = g(class{1}, single(target));
display(num2str(error));