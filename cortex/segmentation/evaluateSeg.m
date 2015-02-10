function eval = evaluateSeg( segmentation, skeletons, nodeThres )
% Calculate skeleton based split-merger metric, pass a segmentation and
% dense skeletons accordingly

general.maxNrObjects = single(length(unique(segmentation(:))));
general.equivMatrix = zeros(size(skeletons,2), single(max(segmentation(:))));
for l=1:size(skeletons,2)
    if size(skeletons{l}.nodes,1) > 0
        nodes{l} = skeletons{l}.nodes(:,1:3);
        for m=1:size(nodes{l},1)
            if segmentation(nodes{l}(m,1), nodes{l}(m,2), nodes{l}(m,3))
               general.equivMatrix(l,segmentation(nodes{l}(m,1), nodes{l}(m,2), nodes{l}(m,3))) = ...
                    general.equivMatrix(l,segmentation(nodes{l}(m,1), nodes{l}(m,2), nodes{l}(m,3))) + 1;
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

