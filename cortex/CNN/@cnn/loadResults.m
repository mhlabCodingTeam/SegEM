function [results, nrIter] = loadResults(cnet)
% Load all results (errors etc. from a CNN training)

files = dir([cnet.run.savingPath 'saveNet*']);
nrIter = length(files);
if nrIter == 0
	results = struct();
	warning('Empty results');
else
	for i=1:nrIter
		currentSave = load([cnet.run.savingPath files(i).name]);
		if any(strcmp(fieldnames(currentSave), 'error'));
			for j=1:length(currentSave.error)
				results.err(length(currentSave.error)*(i-1)+j) = currentSave.error{j}.all;
			end
		else
			results.err(i) = currentSave.err;
			results.idx(i) = currentSave.random.idx;
			results.flipdimensions(i,:) = currentSave.random.flipdimensions;
			results.permutation(i,:) = currentSave.random.permutation;
		end
	end
end

end

