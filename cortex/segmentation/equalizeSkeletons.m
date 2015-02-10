function skel = equalizeSkeletons(skel)

    % Determine skeleton with maximal inter-node distance
    interNodeDistance = calculateInterNodeDistance(skel);
    [maxVal, maxIdx] = max(interNodeDistance);
    toEqualize = setdiff(1:length(skel),maxIdx);

    % Actual equalization
    for i=1:length(toEqualize)
        % Downsample until other node distances are bigger
        while interNodeDistance(toEqualize(i)) < maxVal
            % Downsample 1% of nodes in each for loop
            for j=1:length(skel{toEqualize(i)})
                r = rand(size(skel{toEqualize(i)}{j}.nodes,1),1);
                toDel = r < .01;
                if any(toDel)
                    skel{toEqualize(i)}{j} = removeNodes(skel{toEqualize(i)}{j}, toDel);
                end
            end
            interNodeDistance(toEqualize(i)) = calculateInterNodeDistance(skel(toEqualize(i)));
        end
    end

end

function interNodeDistance = calculateInterNodeDistance(skel)
    % Calculates inter-node distance in (multiple) dense tracings with (multiple) trees each
    for i=1:length(skel)
        nrNodes = [];
        for j=1:length(skel{i})
            nrNodes(j) = size(skel{i}{j}.nodes,1);
        end
        nodes(i) = sum(nrNodes);
        pathLength(i) = getPathLength(skel{i});
    end
    interNodeDistance = pathLength./nodes;
end

function skel = removeNodes(skel, toDel)
    % Remove nodes from skeleton according to logical in 2nd Argument
    ids = 1:size(skel.nodes,1);
    skel.nodes(toDel,:) = [];
    skel.nodesNumDataAll(toDel,:) = [];
    skel.nodesAsStruct(toDel) = [];
    idsToDel = ids(toDel);
    idsToKeep = ids(~toDel);
    for ii=1:length(idsToDel)
        edgesToDel = skel.edges == idsToDel(ii);
        [row,col] = find(edgesToDel);
        col(col==2) = 0;
        col = col + 1;
        idsToJoin = skel.edges(row,col);
        idsToJoin = idsToJoin(:);
        idsToJoin(idsToJoin == idsToDel(ii)) = [];
        idsToJoin = unique(idsToJoin);
        skel.edges(row,:) = [];
        for j=2:length(idsToJoin)
            skel.edges(end+1,:) = [idsToJoin(1) idsToJoin(j)];
        end
    end
    for ii=1:length(idsToKeep)
        skel.edges(skel.edges == idsToKeep(ii)) = ii;
    end
end

