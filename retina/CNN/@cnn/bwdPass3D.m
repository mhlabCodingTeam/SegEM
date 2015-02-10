function sensitivity = bwdPass3D(cnet, activity, activityWithoutNL, target, mask)
sensitivity = cell(cnet.numLayer,cnet.numFeature);
for label=1:cnet.numLabels
sensitivity{cnet.numLayer,label} = cnet.lossFunctionD( activity{cnet.numLayer,label},cnet.run.actvtTyp(target{label})) ...
    .*cnet.run.actvtTyp(mask{label}).*cnet.nonLinearityD(activityWithoutNL{cnet.numLayer,label});
end
for layer=cnet.numLayer:-1:3 % iteration over layers, starting with the last
    for prevFm=1:cnet.layer{layer-1}.numFeature % iteration over featuremaps of the previous layer
        sensitivity{layer-1,prevFm} = zeros(size(activityWithoutNL{layer-1,prevFm}), class(cnet.run.actvtTyp(1)));
        for fm=1:cnet.layer{layer}.numFeature % iteration over featuremaps of this layer
            sensitivity{layer-1,prevFm} = sensitivity{layer-1,prevFm} + ...
                convn(sensitivity{layer,fm}, cnet.run.actvtTyp(cnet.flipdims(cnet.layer{layer}.W{prevFm,fm})));% was W{fm}
        end
        sensitivity{layer-1,prevFm} = sensitivity{layer-1,prevFm}.*cnet.nonLinearityD(activityWithoutNL{layer-1,prevFm});
    end
end