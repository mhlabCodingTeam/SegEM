function result = onlyFwdPass3D(cnet, input)
% Fwd Pass only returining output, not intermediate activities in network

% Load data with right border for cnet
clear gpu_hook;
cnet = cnet.forWeights(cnet.run.actvtClass);
activity = cell(cnet.numLayer, max(cnet.numFeature));
activity{1,1} = cnet.run.actvtClass(input);
% DO the THING (see fwdPass.m without keeping intermediates)
layer = 2;
while size(activity,1) > 1
	for fm=1:cnet.layer{layer}.numFeature
		activity{2,fm} = zeros(size(activity{1,1}) - cnet.filterSize + [1 1 1], class(activity{1,1}));
		for oldFm=1:cnet.layer{layer-1}.numFeature
			activity{2, fm} = activity{2, fm} + convn(activity{1, oldFm}, cnet.layer{layer}.W{oldFm,fm}, 'valid');
		end
		activity{2, fm} = cnet.nonLinearity(activity{2, fm} + cnet.layer{layer}.B(fm));
	end
	activity(1,:) = [];
	layer = layer + 1;
end
% Pass on result
result = single(activity{1,1});
clear gpu_hook;

end
