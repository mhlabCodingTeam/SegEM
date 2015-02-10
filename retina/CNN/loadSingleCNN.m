function [result, nrIter] = loadSingleCNN( path, iter )
%[results, nrIter] = loadCNNResults( path )

nrIter = length(dir([path 'saveNet' '*']));
if nrIter == 0
    result = struct();
else
    if nargin == 1
        iter = nrIter;
    end
    load([path 'saveNet' num2str(iter, '%010.0f') '.mat']);
    result = eval('cnet');
end



end

