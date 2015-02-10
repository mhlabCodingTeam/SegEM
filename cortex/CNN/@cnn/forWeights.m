function [ cnet ] = forWeights( cnet,f )
% Apply a function to all free/learned parameters of the CNN

% Weights
for i=2:cnet.numLayer
    for j=1:cnet.layer{i-1}.numFeature
        for k=1:cnet.layer{i}.numFeature
            cnet.layer{i}.W{j,k} = f(cnet.layer{i}.W{j,k});
        end
    end
end

% Biases
for i=2:cnet.numLayer
	cnet.layer{i}.B = f(cnet.layer{i}.B);
end

end
