function plotResults(hyper, stacks, iter)

% Save to sync for ease of transfer & visualization
hyper.saveDir = strrep(hyper.saveDir, 'results', 'sync');

% Start plot of all net activities on CPU jobmanger
for i=1:hyper.gpuToUse
	hyper.cnet(iter,i) = hyper.cnet(iter,i).loadLastCNN;
	hyper.cnet(iter,i).run.savingPath = strrep(hyper.cnet(iter,i).run.savingPath, 'results', 'sync');
	startCPU(@plotNetActivities, {hyper.cnet(iter,i), stacks});
	startCPU(@plotNetActivitiesFull, {hyper.cnet(iter,i), stacks});
end

% Plot error plots
startCPU(@plotError, {hyper.results{iter}.data, hyper.saveDir, iter});
startCPU(@plotErrorBinned, {hyper.results{iter}.data, hyper.saveDir iter});
startCPU(@plotErrorResorted, {hyper.results{iter}.data, hyper.saveDir, iter});

end

