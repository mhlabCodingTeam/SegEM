function skel = correctSkeletonsToBBox( skel, sizeCube )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin == 1
    sizeCube = [384 384 384];
end
allToBig = [0 0 0];
allToSmall = [0 0 0];
allToDel = 0;

for l=1:size(skel,2)
    if isfield(skel{l}, 'nodesNumDataAll')
        % Correct for skeletons running out of minicube
        tooSmall = skel{l}.nodesNumDataAll(:,3:5) < ones(size(skel{l}.nodesNumDataAll,1),3);
        tooBig = skel{l}.nodesNumDataAll(:,3:5) > repmat(sizeCube,size(skel{l}.nodesNumDataAll,1),1);
        toDel = any(tooSmall,2) | any(tooBig,2);
        if any(toDel)
            display(['Skeleton ' num2str(l) ': Nodes to be removed: ' num2str(sum(tooSmall,1)) ' too small, ' num2str(sum(tooBig,1)) ' too big.']);
            allToBig = allToBig + sum(tooBig,1);
            allToSmall = allToSmall + sum(tooSmall,1);
            allToDel = allToDel + sum(toDel);
        end
        skel{l}.nodesNumDataAll(toDel,:) = []; 
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
        if sum(toDel ~= 0)
            display(['Skeleton ' num2str(l) ': ' num2str(sum(toDel)) ' nodes removed.']);
        end
    end
end
display('TOTAL:');
display(['Nodes removed: ' num2str(allToSmall) ' too small, ' num2str(allToBig) ' too big.']);
display(['Total number: ' num2str(allToDel) ' nodes removed.']);
end
