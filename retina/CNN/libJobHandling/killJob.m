function killJob( numbers )
%killJob( jobIDsToKill )
%   Kills jobs with same parameters as cnet
load /zdata/manuel/fermatResults/activeJobs.mat;

nets = fieldnames(jobs);
jobIDs = cell(length(numbers),1);
randNumber = cell(length(numbers),1);
for nr =1:length(numbers)
    for i=1:length(nets)
        if sum(jobs.(nets{i}).rand == numbers{nr});
            jobIDs{nr} = jobs.(nets{i}).id;
            randNumber{nr} = jobs.(nets{i}).rand;
        end
    end
end
jobIDs(cellfun('isempty',jobIDs)) = [];
randNumber(cellfun('isempty',randNumber)) = [];
jm = findResource('scheduler', 'type', 'jobmanager', 'configuration', 'FermatGPU');
for i = 1:length(jobIDs)
    job = findJob(jm, 'Username', 'mberning', 'ID', jobIDs{i});
    destroy(job);
    jobs = rmfield(jobs, ['net' num2str(randNumber{i}, '%6.6u')]);
end

save('/zdata/manuel/fermatResults/activeJobs.mat', 'jobs');

end

