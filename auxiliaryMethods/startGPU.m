function job = startGPU( functionHandle, inputCell, jobName, nrOutputArguments )
global GLOBAL_HOST;

if nargin < 4
    nrOutputArguments = 0;
end


% We only need CNN path dependencies on the GPU part of the cluster
pathDependencies = {'/usr/local/jacket/' '/usr/local/jacket/engine/' '/zdata/manuel/code/CNN/' '/zdata/manuel/code/auxiliaryMethods/' '/zdata/manuel/code/auxiliaryMethods/cubes/' '/zdata/manuel/code/pipeline/'};

% Load cluster configuration
jm = findJm();
% Create job on cluster
if strcmp(GLOBAL_HOST,'fermat01')
    job = createJob(jm(2), 'RestartWorker', true, 'PathDependencies', pathDependencies, 'Name', jobName);
    for i=1:length(functionHandle);
    	createTask(job, functionHandle{i}, nrOutputArguments, inputCell{i}, 'MaximumNumberOfRetries', 5, 'Timeout', 90000, 'CaptureCommandWindowOutput', 0);
    end
elseif strcmp(GLOBAL_HOST, 'gaba')
    job = createJob(jm(2), 'RestartWorker', true, 'Name', jobName);
    job.AdditionalPaths = {'/gaba/u/mberning/code/CNN/' '/gaba/u/mberning/code/pipeline/' '/gaba/u/mberning/code/auxiliaryMethods/' '/gaba/u/mberning/code/auxiliaryMethods/cubes/'};
    job.AutoAttachFiles = false;
    for i=1:length(functionHandle);
    	createTask(job, functionHandle{i}, nrOutputArguments, inputCell{i});
    end
end
% Start job
submit(job);

end

