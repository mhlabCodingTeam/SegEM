function [activity, activityWithoutNL] = fwdPass3D(cnet, input)
activity = cell(cnet.numLayer, cnet.numFeature);
activityWithoutNL = cell(cnet.numLayer, cnet.numFeature);
% Cast input to right type in output array & start computation
activity{1,1} = cnet.run.actvtTyp(input);
for layer=2:cnet.numLayer
    for fm=1:cnet.layer{layer}.numFeature
        activity{layer,fm} = zeros(size(input) - (layer - 1) * (cnet.filterSize - 1), class(cnet.run.actvtTyp(1)));
        for oldFm=1:cnet.layer{layer-1}.numFeature
            activity{layer, fm} = activity{layer, fm} + convn(activity{layer-1, oldFm}, ...
                cnet.run.actvtTyp(cnet.layer{layer}.W{oldFm,fm}), 'valid');
        end
        activityWithoutNL{layer, fm} = activity{layer, fm} + cnet.layer{layer}.B(fm);
        activity{layer, fm} = cnet.nonLinearity(activityWithoutNL{layer, fm});
    end
end
end