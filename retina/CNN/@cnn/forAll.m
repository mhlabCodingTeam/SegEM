function [ cnet ] = forAll( cnet,f )
%FORALL Summary of this function goes here
%   Detailed explanation goes here

for i=2:cnet.numLayer
    for j=1:cnet.layer{i-1}.numFeature
        for k=1:cnet.layer{i}.numFeature
            cnet.layer{i}.W{j,k} =f(cnet.layer{i}.W{j,k});
        end
    end
    cnet.layer{i}.B = f(cnet.layer{i}.B);
end
end

