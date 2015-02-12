function parameterSearch(hyper)
% Hyperparameter search for learning rates weights and biases in each layer

    % Locate GPU job manager
	jm = parcluster('local');

	% Load raw and target data
	load([hyper.stackFolder 'parameter.mat']);
	stacks = removeSomaStacks(stacks, stackDir);

	% Main loop for parameter iteration
	for iter=1:hyper.iterations
		% Create parameter set
		display(['[' datestr(clock, 21) '] Creating parameters: ' num2str(iter, '%.2i')]);
		tic;
		for i=1:length(hyper.param)
			hyper.param(i).rates{iter} = 10.^(repmat(hyper.param(i).min,hyper.gpuToUse,hyper.param(i).nr) + (hyper.param(i).max - hyper.param(i).min) .* rand(hyper.gpuToUse,hyper.param(i).nr)); 	
		end
		toc
		% Set up class instances and start
		display(['[' datestr(clock, 21) '] Starting evaluation of CNN: ' num2str(iter, '%.2i')]);
		tic;
		for gpu=1:hyper.gpuToUse
			runSetting = train([100 100 100], [hyper.saveDir 'iter' num2str(iter, '%.2i') '/gpu' num2str(gpu, '%.2i') '/'], 3e4, hyper.param(1).rates{iter}(gpu,:), hyper.param(2).rates{iter}(gpu,:));
			if iter == 1
				cnet = cnn(4, [10 10 10 10], [11 11 5], runSetting);
				hyper.cnet(iter,gpu) = cnet.init;
				cnet = cnet.init;
                % Change a few things for plotting
				cnet.run.savingPath = strrep(cnet.run.savingPath, 'iter01', 'start');
                cnet.run.
				startCPU(@plotNetActivitiesFull, {cnet, stacks});
			else	
				hyper.cnet(iter,gpu) = hyper.cnet(iter-1, hyper.results{iter-1}.win(ceil(gpu./(hyper.gpuToUse./hyper.nrNetsToKeep))).idx);
				hyper.cnet(iter,gpu) = hyper.cnet(iter,gpu).loadLastCNN;
				hyper.cnet(iter,gpu).run = runSetting;
			end
			gpuJobs(gpu) = startCNN(hyper.cnet(iter,gpu), stacks);
		end
		save([hyper.saveDir 'parameter' num2str(iter, '%.2i') '.mat'], 'hyper', '-v7.3');
		toc
		display(['[' datestr(clock, 21) '] Started evaluation of CNN(s): ' num2str(iter, '%.2i')]);
		% Waiting loop with intermediate information
		for time=1:hyper.timeEachIteration
			pause(60*60);
			display([num2str(iter, '%.2i') ' Waiting for CNN evalutaion on GPU: ' num2str(time, '%.3i') '/' num2str(hyper.timeEachIteration, '%.3i') ' hours passed.']);
			display([num2str(iter, '%.2i') ' A little check whether GPU are still running: ' num2str(jm.NumberOfBusyWorker) '/' num2str(hyper.gpuToUse)]);
		end
		% Get all results
		display(['[' datestr(clock, 21) '] Killing jobs & evaluating results from iteration ' num2str(iter, '%.2i')]);
		tic;
		destroy(gpuJobs);
		clear gpuJobs;
		hyper.results{iter} = getResults(hyper.cnet(iter,:));		
		toc
		% Select survivors accordingly
		display(['[' datestr(clock, 21) '] Selecting survivors from iteration ' num2str(iter, '%.2i')]);
		tic;
		hyper = selectBestPerformers(hyper, iter);
		for i=1:length(hyper.param)
			hyper.param(i).min = hyper.param(i).min-0.2;
			hyper.param(i).max = hyper.param(i).max-0.2;
		end
		toc
		% Plot activities and error of all nets (using CPU jobmanager);
		display(['[' datestr(clock, 21) '] Initalizing plotting of results on CPU jobmanger for iteration ' num2str(iter, '%.2i')]);
		tic;
		plotResults(hyper, stacks, iter);
		toc
		if iter == hyper.iterations
			save([hyper.saveDir 'final.mat'], 'hyper', '-v7.3');
		end
	end
end
