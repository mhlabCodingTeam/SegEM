function gradient = gradientPass(cnet, activity, sensitivity)
% Calculate gradient from result fwdPass and bwdPass

for layer=2:cnet.numLayer
	for prevFm=1:cnet.layer{layer-1}.numFeature
		for fm=1:cnet.layer{layer}.numFeature
			gradient.layer{layer}.W{prevFm,fm} = cnet.run.saveClass(cnet.flipdims(convn(activity{layer-1,prevFm}, cnet.flipdims(sensitivity{layer,fm}), 'valid')));
		end
	end
	gradient.layer{layer}.B = zeros(1,cnet.layer{layer}.numFeature);
	for fm=1:cnet.layer{layer}.numFeature
		gradient.layer{layer}.B(fm) = sum(sensitivity{layer,fm}(:));
	end
end

end
