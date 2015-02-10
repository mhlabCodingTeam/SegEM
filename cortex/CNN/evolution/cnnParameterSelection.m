%% Example usage of CNN hyperparameter automated selection
% This file shows basic usage of learning rate hyperparameter optimization
% If parameter search is running it will print status each hour to the command line
% and output visualization(s) to saveFolder every 24h
stackFolder = [dataDirectory 'onlineMaterial' filesep 'extracted' filesep];
saveFolder = [outputDirectory filesep 'CNNparameterSearch'];

%% Settings for parameter search

% General settings
hyper.gpuToUse = 28; % GPUs used for each iteration; has to be multiple of nrNetsToKeep
hyper.iterations = 28; % iterations of randomization & selection procedure
hyper.timeEachIteration = 24; % in hours
hyper.nrNetsToKeep = 14; % after each iteration

% Save location
hyper.start = datestr(clock, 30);
hyper.saveDir = [saveFolder filesep hyper.start filesep];
if ~exist(hyper.saveDir, 'dir')
    mkdir(hyper.saveDir);
end

% Where to find training stacks
hyper.stackFolder = stackFolder;

% Settings for metaparameter variation
% 10^param(1) = Range for weight variation
% 10^param(2) = Range for bias variation
hyper.param(1).min = -10;
hyper.param(1).max = -9;
hyper.param(1).nr = 5; % individual learning rate for each layer
hyper.param(2).min = -10;
hyper.param(2).max = -9;
hyper.param(2).nr = 5;

%% Search hyperparameter (for CNN architecture see file)
parameterSearch(hyper);

%% In case something goes wrong, continue after a specific iteration
continueParameterSearch(hyper, 3);
