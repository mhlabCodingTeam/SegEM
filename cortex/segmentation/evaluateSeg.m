function eval = evaluateSeg( segmentation, skeletons, nodeThres, nodeSize )
% Calculate skeleton based split-merger metric, pass a segmentation and
% dense skeletons accordingly

if nargin == 3
    nodeSize = 1;
end

general.maxNrObjects = single(length(unique(segmentation(:))));
general.equivMatrix = zeros(size(skeletons,2), single(max(segmentation(:))));
general.zeroHits = 0;
general.nodesTotal = 0;
for l=1:size(skeletons,2)
    if size(skeletons{l}.nodes,1) > 0
        nodes{l} = skeletons{l}.nodes(:,1:3);
        for m=1:size(nodes{l},1)
            centerNode = [nodes{l}(m,1) nodes{l}(m,2) nodes{l}(m,3)];
            nodeIDs = segmentation(max((centerNode(1)-(nodeSize-1)/2),1):min((centerNode(1)+(nodeSize-1)/2),size(segmentation,1)), ...
                max((centerNode(2)-(nodeSize-1)/2),1):min((centerNode(2)+(nodeSize-1)/2),size(segmentation,2)), ...
                max((centerNode(3)-(nodeSize-1)/2),1):min((centerNode(3)+(nodeSize-1)/2),size(segmentation,3)));
            nodeIDs = unique(nodeIDs(:));
            general.zeroHits = general.zeroHits + sum(nodeIDs == 0);
            general.nodesTotal = general.nodesTotal + 1;
            nodeIDs(nodeIDs == 0) = [];
            for i=1:length(nodeIDs)
               general.equivMatrix(l,nodeIDs(i)) = general.equivMatrix(l,nodeIDs(i)) + 1;
            end
        end
    end              
end
general.equivMatrixBinary = general.equivMatrix >= nodeThres;
% Calculate Splits
split.vec = sum(general.equivMatrixBinary,2);
split.idx = find(split.vec > 1);
split.obj = cell(length(split.idx),1);
for m=1:length(split.idx)
    split.obj{m} = find(general.equivMatrixBinary(split.idx(m),:));
end
split.sum = sum(split.vec(split.idx)-1);
% Calculate Merger
merge.vec = sum(general.equivMatrixBinary,1);
merge.idx = find(merge.vec > 1);
merge.obj = cell(length(merge.idx),1);
for m=1:length(merge.idx)
    merge.obj{m} = find(general.equivMatrixBinary(:,merge.idx(m)));
end
merge.sum = sum(merge.vec(merge.idx)-1);

% Output all in case we need it again xD
eval.general = general;
eval.nodes = nodes;
eval.split = split;
eval.merge = merge;

end

