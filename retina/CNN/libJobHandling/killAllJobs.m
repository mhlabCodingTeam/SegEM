function killAllJobs(which, finished)
%killJob( jobIDsToKill )
%   Kills jobs on "which" jobmanager (if finsished = 1, only finshed jobs)

jm = findResource('scheduler', 'type', 'jobmanager', 'LookupURL', 'fermat01');
if any(which == 1)
    if finished
        jobs = findJob(jm(1), 'Username', 'mberning', 'state', 'finished');
    else
        jobs = findJob(jm(1), 'Username', 'mberning');
    end
    if ~isempty(jobs)
        destroy(jobs);
    end
end
if any(which == 2)
    if finished
        jobs = findJob(jm(2), 'Username', 'mberning', 'state', 'finished');
    else
        jobs = findJob(jm(2), 'Username', 'mberning');
    end
    if ~isempty(jobs)
        destroy(jobs);
    end
end
delete('/zdata/manuel/fermatResults/activeJobs.mat');

end

