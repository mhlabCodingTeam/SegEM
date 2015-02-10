function [results, nrIter] = loadCNNResults( path, var )
%[results, nrIter] = loadCNNResults( path )
% var = {'cnet', 'failReport', 'currentStack', 'rngState', 'error', 'randEdges'};
% Switch warnings off because jobs and workers can not be recieved an will
% produce error each
warning off;
nrIter = length(dir([path 'saveNet' '*']));
if nrIter == 0
    results = struct();
end
for i=1:nrIter
    load([path 'saveNet' num2str(i, '%010.0f') '.mat']);
    for v=1:length(var)
        results.(var{v}){i} = eval(var{v});
    end
end
warning on;
end

