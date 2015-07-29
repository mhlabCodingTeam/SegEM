function eval = evaluateSeg( segmentation, skeletons, nodeThres )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

general = struct('equivMatrix', {}, 'maxNrObjects', {});
nodes = cell(length(size(skeletons,2)),1);
split = struct('vec', {}, 'idx', {}, 'obj', {}, 'sum', {});
merge = struct('vec', {}, 'idx', {}, 'obj', {}, 'sum', {});
for i=1:size(segmentation,1)
    for j=1:size(segmentation,2)
        for k=1:size(segmentation,3)
            display(num2str([i j k]));
            general(i,j,k).maxNrObjects = single(length(unique(segmentation{i,j,k}(:))));
            general(i,j,k).equivMatrix = zeros(size(skeletons,2), single(max(segmentation{i,j,k}(:))));
            for l=1:size(skeletons,2)
                if size(skeletons{l}.nodes,1) > 1
                    nodes{l} = skeletons{l}.nodes(:,1:3);
                    for m=1:size(nodes{l},1)
                        if segmentation{i,j,k}(nodes{l}(m,1), nodes{l}(m,2), nodes{l}(m,3))
                           general(i,j,k).equivMatrix(l,segmentation{i,j,k}(nodes{l}(m,1), nodes{l}(m,2), nodes{l}(m,3))) = ...
                                general(i,j,k).equivMatrix(l,segmentation{i,j,k}(nodes{l}(m,1), nodes{l}(m,2), nodes{l}(m,3))) + 1;
                        end
                    end
                end
            end
            general(i,j,k).equivMatrixBinary = general(i,j,k).equivMatrix >= nodeThres;
            % Calculate Splits
            split(i,j,k).vec = sum(general(i,j,k).equivMatrixBinary,2);
            split(i,j,k).idx = find(split(i,j,k).vec > 1);
            split(i,j,k).obj = cell(length(split(i,j,k).idx),1);
            for m=1:length(split(i,j,k).idx)
                split(i,j,k).obj{m} = find(general(i,j,k).equivMatrixBinary(split(i,j,k).idx(m),:));
            end
            split(i,j,k).sum = sum(split(i,j,k).vec(split(i,j,k).idx)-1);
            % Calculate Merger
            merge(i,j,k).vec = sum(general(i,j,k).equivMatrixBinary,1);
            merge(i,j,k).idx = find(merge(i,j,k).vec > 1);
            merge(i,j,k).obj = cell(length(merge(i,j,k).idx),1);
            for m=1:length(merge(i,j,k).idx)
                merge(i,j,k).obj{m} = find(general(i,j,k).equivMatrixBinary(:,merge(i,j,k).idx(m)));
            end
            merge(i,j,k).sum = sum(merge(i,j,k).vec(merge(i,j,k).idx)-1);
        end
    end
end

eval.general = general;
eval.nodes = nodes;
eval.split = split;
eval.merge = merge;

end

