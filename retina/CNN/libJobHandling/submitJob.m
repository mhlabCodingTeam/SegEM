function submitJob( cnet, dataRaw, dataTrace, outputDir )
%createJob( cnet )
%   Create Job training CNN on cluster

% Load parcluster configuration
global jobManagerName;
jm = parcluster(jobManagerName);

% Create random string for identification of network
rng('shuffle'); % Set RNG to 'random' state based on time
randNumber = floor(rand*1000000);
randString = [date filesep 'net' num2str(randNumber, '%6.6u')];
resultDir = [outputDir randString filesep];

% Create Directories for saving results & start learning
if(exist(resultDir,'dir'))
    error(['Folder already exsits: ' resultDir ' Please retry.']);
else
    mkdir(resultDir);
    cnet.run.savingPath = resultDir;
    % Create job on cluster
    job = createJob(jm);
    inputargs = {cnet, dataRaw, dataTrace};
    createTask(job, @trainGradient, 1, inputargs);
    % Save CNN Parameter values to Excel File
    saveJobParamToXls(cnet, [resultDir filesep date filesep]);
    % Start job and save job in "DB"
    if exist([resultDir filesep 'activeJobs.mat'], 'file')
        load([resultDir filesep 'activeJobs.mat']);
    end
    jobs.(['net' num2str(randNumber, '%6.6u')]).rand = randNumber;
    jobs.(['net' num2str(randNumber, '%6.6u')]).date = date;
    jobs.(['net' num2str(randNumber, '%6.6u')]).id = job.ID;
    save([resultDir filesep 'activeJobs.mat'], 'jobs');
    submit(job);
end

end

