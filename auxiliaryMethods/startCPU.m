function job = startCPU( functionHandle, inputCell, jobName )
    global jobManagerName;
    
    % Load cluster configuration
    jm = parcluster(jobManagerName);
    
    % Create job on cluster
    job = createJob(jm(1), 'Name', jobName);
    for i=1:length(functionHandle)
        createTask(job, functionHandle{i}, 0, inputCell{i});
    end

    % Start job
    submit(job);

end
