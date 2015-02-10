function submitJob( cnet, dataRaw, dataTrace )
%createJob( cnet )
%   Create Job training CNN on cluster

% Load cluster configuration
jm = findResource('scheduler', 'type', 'jobmanager', 'configuration', 'FermatGPU_CNN');

% Create random string for identification of network
rng('shuffle');
randNumber = floor(rand*1000000);
randString = [date '/' 'net' num2str(randNumber, '%6.6u')];
resultDir = ['/zdata/manuel/fermatResults/' randString '/'];

% Create Directories for saving results & start learning
if(exist(resultDir,'dir'))
    error(['Folder already exsits: ' resultDir ' Please retry.']);
else
    mkdir(resultDir);
    cnet.run.savingPath = resultDir;
    % Create job on cluster
    job = createJob(jm, 'configuration', 'FermatGPU_CNN');
    inputargs = {cnet, dataRaw, dataTrace};
    createTask(job, @trainGradient, 1, inputargs, 'configuration', 'FermatGPU_CNN');
    % Save CNN Parameter values to Excel File
    saveJobParamToXls(cnet, ['/zdata/manuel/sync/toP1-377/PDF/' date '/']);
    % Start job and save job in "DB"
    if exist('/zdata/manuel/fermatResults/activeJobs.mat', 'file')
        load('/zdata/manuel/fermatResults/activeJobs.mat');
    end
    jobs.(['net' num2str(randNumber, '%6.6u')]).rand = randNumber;
    jobs.(['net' num2str(randNumber, '%6.6u')]).date = date;
    jobs.(['net' num2str(randNumber, '%6.6u')]).id = job.ID;
    save('/zdata/manuel/fermatResults/activeJobs.mat', 'jobs');
    submit(job);
end

end

