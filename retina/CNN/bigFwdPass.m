function bigFwdPass( cnet, input, result, datasetSize)
jm = findResource('scheduler', 'type', 'jobmanager', 'LookupURL', 'fermat01');
jm = jm(1);
pathToAdd = {'/path/to/some/directory/code/CNN/', '/path/to/some/directory/code/aux/', '/usr/local/jacket/', '/usr/local/jacket/engine/'};
nrIter = ceil(datasetSize / 128);
for i=1:nrIter(3)
    job = createJob(jm);
    set(job, 'PathDependencies', pathToAdd);
    set(job, 'RestartWorker', 1);
    set(job, 'UserName', 'mberning');	
    for j=1:nrIter(2)
        for k=1:nrIter(1)
            % Account for cubeIDs starting at 0 instead of 1
            input.cube = [k-1; j-1; i-1];
            inputargs = {cnet, input, result};
            task = createTask(job, @fwdPass3Dfaster, 0, inputargs);
            set(task, 'MaximumNumberOfRetries', 5);
        end
    end
    submit(job);
end

end

