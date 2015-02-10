function skel = switchToLocalCoords( skel, cubeIDs, cubeSwitch )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin == 2 || cubeSwitch == 1
    for l=1:size(skel,2)
        if isfield(skel{l}, 'nodesNumDataAll')
            skel{l}.nodesNumDataAll(:,3:5) = skel{l}.nodesNumDataAll(:,3:5) - repmat(( cubeIDs * 128) + [0 0 0],size(skel{l}.nodesNumDataAll,1),1);
        end
    end
else
     for l=1:size(skel,2)
        if isfield(skel{l}, 'nodesNumDataAll')
            skel{l}.nodesNumDataAll(:,3:5) = skel{l}.nodesNumDataAll(:,3:5) - repmat(cubeIDs,size(skel{l}.nodesNumDataAll,1),1);
        end
    end   
end

end

