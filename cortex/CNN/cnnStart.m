%% Example usage of CNN class
% This file shows basic usage of a 3D-convolutional neural network

%% Load raw and trace data
stackFolder = [dataDirectory 'onlineMaterial' filesep 'extracted' filesep];
load([stackFolder filesep 'parameter.mat']);
clear settings;

%% Fix metadata of stacks for use with new data location
for i=1:length(stacks)
    stacks(i).targetFile = strrep(stacks(i).targetFile, ...
        '/zdata/manuel/data/cortex/20130919T033350/', stackFolder);
    stacks(i).targetFile = strrep(stacks(i).targetFile, '/', filesep);
    stacks(i).stackFile = strrep(stacks(i).stackFile, ...
        '/zdata/manuel/data/cortex/20130919T033350/', stackFolder);
    stacks(i).stackFile = strrep(stacks(i).stackFile, '/', filesep);
end
clear stackFolder i;

%% visualize some (arbitrary) stack
stackNr = 1;
load(stacks(stackNr).stackFile);
load(stacks(stackNr).targetFile);
makeSegMovie(stack, raw(51:150,51:150,26:125), [outputDirectory filesep 'stackVideo.avi']);
makeIsosurfaceView(stack, raw(51:150,51:150,26:125), [outputDirectory filesep 'stackView.png']);

%% Set up class objects
runSetting = train([100 100 100], [outputDirectory filesep 'CNNdebug' filesep], ...
    1e4, [1e-6 1e-6 1e-6 1e-6 1e-6], [1e-8 1e-8 1e-8 1e-8 1e-8]);
% Produce more ouput
runSetting.debug = true;
% Run on GPU, set to runSetting.actvtClass = @single in case of errors;
% (you can try setting this to gpuarray (MATLAB) or gsingle (Accelereyes JACKET))
% Requires Nvidia GPU and CUDA > 4.0 (?)
if gpuDeviceCount > 1
    runSetting.actvtClass = @gpuArray;
else
	runSetting.actvtClass = @single;
end
cnet = cnn(4,[10 10 10 10],[21 21 11], runSetting);
cnet = cnet.init;
clear runSetting;

%% Train CNN
cnet.learn(stacks);

%% Plot CNN activity (if not trained for long/not at all activity should be gray with little variations in most layers)
cnet.plotNetActivities(stacks);
cnet.plotNetActivitiesFull(stacks);

%% Load and visualize a trained CNN:
load([dataDirectory filesep 'supplement' filesep 'extracted' filesep 'cortex - CNN20130516T204040_8_3.mat']);
cnet.run.savingPath = strrep(cnet.run.savingPath, ...
    '/zdata/manuel/results/parameterSearch/20130516T204040/iter08/gpu03/', [outputDirectory filesep 'trainedCNN' filesep]);
if gpuDeviceCount > 1
    cnet.run.actvtClass = @gpuArray;
else
	cnet.run.actvtClass = @single;
end
cnet.plotNetActivities(stacks);
cnet.plotNetActivitiesFull(stacks);
