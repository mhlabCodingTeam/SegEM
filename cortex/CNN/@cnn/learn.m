function learn( cnet, stacks )
% Learns weights of cnet according to stacks

% This is abundant in this code, always use before/after using GPUs -> Jacket Bug?
clear gpu_hook; 

% Set Matlab RNG to random state (random values will be saved with CNN)
rng('shuffle');

w = getCurrentWorker();
if ~isempty(w)
    w = w.Name;
    gselect(str2double(w(16:17)));
end

% Check whether directory exsist and create otherwise
if ~exist(fullfile(cnet.run.savingPath),'dir')
    mkdir(fullfile(cnet.run.savingPath));
end

% Load all training cubes into array (assumes 100^3 stacks so far)
% Keep in memory (RAM of CPU, takes ~14.5 GB) for decresed I/O
sizeRaw = [100 100 100] + cnet.randOfConvn;
borderRaw = ([100 100 50] - cnet.randOfConvn)/2;
cubeRaw = zeros(sizeRaw(1), sizeRaw(2), sizeRaw(3), length(stacks));
cubeTarget = zeros(100, 100, 100, length(stacks));
for i=1:length(stacks)
	load(stacks(i).targetFile);
	if cnet.normalize
		cubeRaw(:,:,:,i) = normalizeStack(single(raw(1+borderRaw(1):end-borderRaw(1),1+borderRaw(2):end-borderRaw(2),1+borderRaw(3):end-borderRaw(3))));
	else
		cubeRaw(:,:,:,i) = single(raw(1+borderRaw(1):end-borderRaw(1),1+borderRaw(2):end-borderRaw(2),1+borderRaw(3):end-borderRaw(3)));
	end
	cubeTarget(:,:,:,i) = single(target);
end

for iid=1:cnet.run.maxIter
    % Get random stack, permutation (of x,y only due to anisotropy) & 
	random.idx = randi(length(stacks),1);
	random.permutation = randperm(2);
	random.flipdimensions = randi(2, 1, 3) - 1;
	% Cast stacks and CNN to GPU
	raw = cnet.run.actvtClass(cubeRaw(:,:,:,random.idx));
	target = cnet.run.actvtClass(cubeTarget(:,:,:,random.idx));
	cnetGPU = cnet.forWeights(cnet.run.actvtClass);
	% Randomly permute x & y dimension and randomly flip all dimensions
	raw = permute(raw, [random.permutation 3]);
	target = permute(target, [random.permutation 3]);
	for i=1:3
		if random.flipdimensions(i)
			raw = flipdim(raw, i);
			target = flipdim(target, i);
		end
	end
	% Pass raw data through CNN
	[activity, activityWithoutNL] = cnetGPU.fwdPass3D(raw);
	% Find sensitivity of output on weights
	[sensitivity, err] = cnetGPU.bwdPass3D(activity, activityWithoutNL, target);
	err = cnet.run.saveClass(err);
	% Compute gradient updates
	gradient = cnetGPU.gradientPass(activity, sensitivity);
	% Update paramaters (stochastic batch gradient descent)
	cnet = cnet.sgd(gradient);
	% Save data if debug flag is on, otherwise just cnet, error and random
	% values
	if cnet.run.debug
		save(fullfile(cnet.run.savingPath,[ 'debug' num2str(iid, '%010.0f') '.mat']));
		system(['chmod 664 ' fullfile(cnet.run.savingPath,[ 'debug' num2str(iid, '%010.0f') '.mat'])]);	
		display(num2str(err));
	end
	save(fullfile(cnet.run.savingPath,[ 'saveNet' num2str(iid, '%010.0f') '.mat']), 'cnet', 'err', 'random');
	system(['chmod 664 ' fullfile(cnet.run.savingPath,[ 'saveNet' num2str(iid, '%010.0f') '.mat'])]);
	clear cnetGPU raw target activity activityWithoutNL sensitivity;
	clear gpu_hook;
end

end
