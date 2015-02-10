function [sensitivity, lossSum] = bwdPass3D(cnet, activity, activityWithoutNL, target)
% Backward pass of error through network

% Initalize
sensitivity = cell(cnet.numLayer,max(cnet.numFeature));
% Calculate error & loss mask in case area not annotated
diff = (activity{cnet.numLayer,1}-target).*(target ~= 0);
loss = cnet.lossFunction(diff);
% Sum up for saving purposes
lossSum = sum(loss(:));
% Do bwdPass wrt to loss Function
sensitivity{cnet.numLayer,1} = cnet.nonLinearityD(activityWithoutNL{cnet.numLayer,1}).*cnet.lossFunctionD(diff);

% Loop backwards
for layer=cnet.numLayer:-1:3    
    for prevFm=1:cnet.layer{layer-1}.numFeature
	sensitivity{layer-1,prevFm} = zeros(size(activity{layer-1,prevFm}), class(target));     
        for fm=1:cnet.layer{layer}.numFeature 
            sensitivity{layer-1,prevFm} = sensitivity{layer-1,prevFm} + convn(sensitivity{layer,fm}, cnet.flipdims(cnet.layer{layer}.W{prevFm,fm}));
        end
    	sensitivity{layer-1,prevFm} = sensitivity{layer-1,prevFm}.*cnet.nonLinearityD(activityWithoutNL{layer-1,prevFm});
    end
end

end

