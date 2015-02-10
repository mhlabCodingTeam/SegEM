function skel = correctSkeletonsToBBox_v2( skel, sizeCube )

skelToDel = zeros(size(skel,2),1);
allTooSmall = zeros(1,3);
allTooBig = zeros(1,3);
for l=1:size(skel,2)
    if isfield(skel{l}, 'nodesNumDataAll') && ~isempty(skel{l}.nodesNumDataAll)
        % Correct for skeletons running out of minicube, remove nodes
        tooSmall = skel{l}.nodesNumDataAll(:,3:5) < ones(size(skel{l}.nodesNumDataAll,1),3);
        tooBig = skel{l}.nodesNumDataAll(:,3:5) > repmat(sizeCube,size(skel{l}.nodesNumDataAll,1),1);
        toDel = any(tooSmall,2) | any(tooBig,2);
        if sum(tooSmall(:)) || sum(tooBig(:))
        	%display(['Nodes to be removed: ' num2str(sum(tooSmall,1)) ' too small, ' num2str(sum(tooBig,1)) ' too big.']);
		allTooSmall = allTooSmall + sum(tooSmall,1);
		allTooBig = allTooBig + sum(tooBig,1);
	end
        skel{l}.nodesNumDataAll(toDel,:) = [];
        skel{l}.nodes(toDel,:) = [];
        skel{l}.nodesAsStruct(toDel) = [];
        % ... remove edges accordingly
        if size(skel{l}.nodes,1)
            edgesToDel = find(toDel);
            edgeIdx = unique(skel{l}.edges(:));
            for idx=1:length(edgesToDel)
                [row,~] = find(edgesToDel(idx) == skel{l}.edges);
                skel{l}.edges(row,:) = [];
                edgeIdx(edgeIdx == edgesToDel(idx)) = [];
            end
            edgeIdxNew = (1:length(edgeIdx))';
            for idx=1:length(edgeIdxNew)
                renumber = skel{l}.edges == edgeIdx(idx);
                skel{l}.edges(renumber) = edgeIdxNew(idx);
            end
        else
            skelToDel(l) = 1;
            %display(['Skeleton ' num2str(l) ': empty after bbox cutoff']);
        end
        %if sum(toDel ~= 0)
        %    display(['Skeleton ' num2str(l) ': ' num2str(sum(toDel)) ' nodes removed. ' num2str(size(skel{l}.nodes,1)) ' nodes remaining']);
        %end
    else
        skelToDel(l) = 1;
    end
end

display(['Nodes removed total for this tracing: ' num2str(allTooSmall) ' too small; ' num2str(allTooBig) ' too big.']);
skel = skel(~skelToDel);

end

