function inputs = getParamCombinations( algo )

    % Loop over each algorithm
    for i=1:length(algo)
        if ~isempty(algo(i).par)
            numParam = length(algo(i).par);
            numParamVariations = cellfun(@length, algo(i).par);
            % Loop over each parameter
            for j=1:prod(numParamVariations)
                [subs{1:numParam}] = ind2sub(numParamVariations, j);
                inputs{i}{j} = {algo(i).fun cellfun(@(x,s)(x(s)), algo(i).par, subs, 'UniformOutput', false)};
            end
        end
    end

end

