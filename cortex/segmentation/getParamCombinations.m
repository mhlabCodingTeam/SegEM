function inputs = getParamCombinations( algo )

    % Loop over each algorithm
    for i=1:length(algo)
        if ~isempty(algo(i).par{1})
            numParam = length(algo(i).par);
            numParamVariations = cellfun(@length, algo(i).par);
            % Loop over each parameter
            for j=1:prod(numParamVariations)
                [subs{1:numParam}] = ind2sub(numParamVariations, j);
                inputs{i}{j} = {algo(i).fun cellfun(@(x,s)(x(s)), algo(i).par, subs, 'UniformOutput', false)};
            end
            % Quick hack, add values from paper segmentations cortex
            inputs{i}{106} = {algo(i).fun {0.39 50}};
            inputs{i}{107} = {algo(i).fun {0.25 10}};
        end
    end

end

