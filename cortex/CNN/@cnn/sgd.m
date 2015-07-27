function cnet = sgd(cnet, gradient)
% Update cnet according to gradient

for layer=2:cnet.numLayer
	if cnet.run.linearRate
		[etaW, etaB] = cnet.run.linearLearn(layer-1); % -1 due to first layer having no parameters
	else
		[etaW, etaB] = cnet.run.expLearn(layer-1);
    end
    if cnet.normalizeLearningRates
        etaW = etaW ./ prod(cnet.run.outputSize);
        etaB = etaB ./ prod(cnet.run.outputSize);
    end
	for prevFm=1:cnet.layer{layer-1}.numFeature
		for fm=1:cnet.layer{layer}.numFeature
			cnet.layer{layer}.W{prevFm,fm} = cnet.layer{layer}.W{prevFm,fm} - etaW.*gradient.layer{layer}.W{prevFm,fm};
		end
	end
	cnet.layer{layer}.B = cnet.layer{layer}.B - etaB.*gradient.layer{layer}.B;
end

