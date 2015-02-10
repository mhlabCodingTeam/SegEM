function fwdPass3Dfaster(cnet, input, result)
% Load & normalize data and make sure single is used
activity = cell(cnet.numLayer, cnet.numFeature);
bbox(:,1) = input.cube(:,1)*128 + 1 - ceil(cnet.randOfConvn'/2) + 1;
bbox(:,2) = (input.cube(:,1) + 1)*128 + ceil(cnet.randOfConvn'/2);
activity{1,1} = readKnossosRoi(input.root, input.prefix, bbox);
clear gpu_hook;
if cnet.normalize
    activity{1,1} = cnet.normalizeStack(cnet.run.actvtTyp(activity{1,1}));
end
% Do the THING
layer = 2;
while size(activity,1) > 1
    for fm=1:cnet.layer{layer}.numFeature
        activity{2,fm} = zeros(size(activity{1,1}) - (cnet.filterSize - 1), class(cnet.run.actvtTyp(1)));
        for oldFm=1:cnet.layer{layer-1}.numFeature
            activity{2, fm} = activity{2, fm} + convn(activity{1, oldFm}, ...
                cnet.run.actvtTyp(cnet.layer{layer}.W{oldFm,fm}), 'valid');
        end
        activity{2, fm} = cnet.nonLinearity(activity{2, fm} + cnet.layer{layer}.B(fm));
    end
    activity(1,:) = [];
    layer = layer + 1;
end
% Save result to 3 KNOSSOS folders
activity(cellfun(@isempty,activity)) = [];
for i=1:size(activity,2)
    writeKnossosCube([result.root result.folders{i} '/'], result.prefix, input.cube, single(activity{1,i}), 'single', '');
end

end
