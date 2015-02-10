function hyper = selectBestPerformers(hyper, iter)
minibatchesEvaluated = 200;

for gpu=1:length(hyper.results{iter}.data)
	nrEval = length(hyper.results{iter}.data(gpu).err);
	start = nrEval - minibatchesEvaluated + 1;
	if start >= 1
		score(gpu) = mean(hyper.results{iter}.data(gpu).err((end - minibatchesEvaluated + 1):end));
	else
		score(gpu) = mean(hyper.results{iter}.data(gpu).err(1:end));	
	end
end
for winner=1:hyper.nrNetsToKeep
	[val, idx] = min(score);
	hyper.results{iter}.win(winner).val = val;
	hyper.results{iter}.win(winner).idx = idx;	
	score(idx) = Inf;
end

end
