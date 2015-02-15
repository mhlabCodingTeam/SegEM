function [cnet, error, randEdges, rngState] = learn( cnet, raw, trace)
%cnet = learn( cnet, currentRaw, target, mask, classT ) Updates weights of
%cnet according to raw data, target and mask

rng('shuffle');
rngState = rng;

if cnet.normalize
    raw = cnet.normalizeStack(single(raw));
end
sizeRaw = size(raw);

% Set number of elements required to enter learning step/ exit while
% loop (see below)
error = cell(cnet.run.maxIterMini, 1);
randEdges = cell(cnet.run.maxIterMini, 1);
for iid2=1:cnet.run.maxIterMini
    for i=1:cnet.run.maxIterRandom
        % Choose patch of size inputSize randomly from the minicube
        randEdge = ceil(rand(1,3).*(sizeRaw - cnet.run.inputSize + ones(1,3)));
        if cnet.run.debugLearn
            randEdge = [110 125 126];
        end
        inputPatch=cell(1,3);
        outputPatch=cell(1,3);
        for dim=1:3
            inputPatch{dim} = randEdge(dim):randEdge(dim) + cnet.run.inputSize(dim) - 1;
            % Account for 'valid' convolutions
            outputPatch{dim} = inputPatch{dim}(ceil(cnet.randOfConvn(dim)/2:end - cnet.randOfConvn(dim)/2));
        end
        % Load Tracing data
        currentTrace = trace(outputPatch{:});
        % Mask area that was not traced
        [target, mask] = cnet.masking(cnet, currentTrace);
        % Special treatment for vesicle run
        if isempty(mask{1})
            load('/path/to/some/directory/e_k0563/vesicle/Masks/e_k0563_ribbon_0124b_vesicles_full_stack_mask.mat');
            mask{1} = KLEE_savedStack(outputPatch{:});
            mask{1}(1,:,:) = [];
            mask{1}(:,1,:) = [];
            mask{1}(:,:,1) = [];
        end
        % Check whether enough tracing data is present in all masks
        % Need to disable this check for vesicle training
        if isempty(cnet.isoBorder)
            break;
        else
            if any(cellfun(@(X)sum(sum(sum(X))),mask) >= ceil(cnet.run.percentageReqElem*numel(mask{1}))) && ...
                   any(cellfun(@(X,Y)sum(sum(sum(X.*Y))),mask,target) <= ceil((1-2*cnet.run.percentageReqEach)*numel(mask{1}))) && ...
                   any(cellfun(@(X,Y)sum(sum(sum(X.*Y))),mask,target) >= -ceil((1-2*cnet.run.percentageReqEach)*numel(mask{1})));
                break;
            end
        end
    end
    % Load corresponding raw data
    currentRaw = raw(inputPatch{:});

    % Pass raw data through CNN
    [activity, activityWithoutNL] = cnet.fwdPass3D(currentRaw);
    % Find sensitivity of output on weights
    sensitivity = cnet.bwdPass3D(activity, activityWithoutNL, target, mask);
    % Compute gradient updates & apply to cnn obj
    cnet = cnet.gradientPass(activity, sensitivity);

    % Save error to struct
    error{iid2}.all = 0;
    error{iid2}.cutoff = 0;
    for i = 1:cnet.numLabels
        temp = cnet.run.saveTyp(sum(sum(sum(cnet.lossFunctionD(target{i}, activity{length(cnet.layer),i}).*mask{i})))...
                /(sum(sum(sum(mask{i})))));
        temp2 = cnet.run.saveTyp(sum(sum(sum(cnet.lossFunctionD(target{i}, min(max(activity{length(cnet.layer),i}, -1),1)).*mask{i})))...
                /(sum(sum(sum(mask{i})))));
        error{iid2}.all = error{iid2}.all + temp;
        error{iid2}.cutoff = error{iid2}.cutoff + temp2;
    end
    error{iid2}.all = error{iid2}.all / cnet.numLabels;
    error{iid2}.cutoff = error{iid2}.cutoff / cnet.numLabels;
    randEdges{iid2} = randEdge;
    cnet.run.iterations = cnet.run.iterations + 1;
end

end

