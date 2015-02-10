function jm = findJm()
global GLOBAL_HOST GLOBAL_CPU_JM GLOBAL_GPU_JM;

switch GLOBAL_HOST
    case 'fermat01'
        jm(1) = findResource('scheduler', 'type', 'jobmanager', 'name', GLOBAL_CPU_JM);
        jm(2) = findResource('scheduler', 'type', 'jobmanager', 'name', GLOBAL_GPU_JM);
    case 'gaba'
        jm(1) = parcluster(GLOBAL_GPU_JM); % Change to CPU as soon as created
        jm(2) = parcluster(GLOBAL_GPU_JM);
    otherwise
        error('Please add your cluster configuration to libjm/findJm.m');
end

end

