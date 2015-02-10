function [activity, activityWithoutNL] = fwdPass3D(cnet, input)
% Forward Pass for network training

% Initalize cell arrays & put input in first layer
activity = cell(cnet.numLayer, max(cnet.numFeature));
activityWithoutNL = cell(cnet.numLayer, max(cnet.numFeature));
activity{1,1}= input;
% Iterate over layers
for layer=2:cnet.numLayer
    for fm=1:cnet.layer{layer}.numFeature
        % Initalize feature map with zeros
        activityWithoutNL{layer,fm} = zeros(size(input) - (layer - 1) * (cnet.filterSize - 1), class(input));
        % Apply weights (all-to-all to previous layer)
        for prevFm=1:cnet.layer{layer-1}.numFeature
            activityWithoutNL{layer, fm} = activityWithoutNL{layer, fm} + convn(activity{layer-1, prevFm}, cnet.layer{layer}.W{prevFm,fm}, 'valid');
        end
        % Apply biases
        activityWithoutNL{layer,fm} = activityWithoutNL{layer,fm} + cnet.layer{layer}.B(fm);
        % Apply nonlinearities
        activity{layer, fm} = cnet.nonLinearity(activityWithoutNL{layer, fm});
    end
end

end
