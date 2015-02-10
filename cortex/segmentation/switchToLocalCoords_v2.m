function skel = switchToLocalCoords_v2( skel, offset )
% Correct nodes, nodesNumDataAll and nodesAsStruct to bbox
for l=1:size(skel,2)
    if isfield(skel{l}, 'nodesNumDataAll') && ~isempty(skel{l}.nodesNumDataAll);
        skel{l}.nodesNumDataAll(:,3:5) = skel{l}.nodesNumDataAll(:,3:5) - repmat(offset,size(skel{l}.nodesNumDataAll,1),1);
    end
    if isfield(skel{l}, 'nodes') && ~isempty(skel{l}.nodes);
        skel{l}.nodes(:,1:3) = skel{l}.nodes(:,1:3) - repmat(offset,size(skel{l}.nodes,1),1);
    end
    if isfield(skel{l}, 'nodesAsStruct') && ~isempty(skel{l}.nodesAsStruct);
        for i=1:length(skel{l}.nodesAsStruct)
            skel{l}.nodesAsStruct{i}.x = skel{l}.nodesAsStruct{i}.x - offset(1);
            skel{l}.nodesAsStruct{i}.y = skel{l}.nodesAsStruct{i}.y - offset(2);
            skel{l}.nodesAsStruct{i}.z = skel{l}.nodesAsStruct{i}.z - offset(3);
        end
    end    
end

end

