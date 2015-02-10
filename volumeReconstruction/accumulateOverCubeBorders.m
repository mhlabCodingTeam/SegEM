function [skel, accStruct] = accumulateOverCubeBorders(skel, aStruct, nameForTree)
    % Pass structure with field voxel (in global coordinates) positions, will be merged if overlapping, name for tree to add to skel

    nrElements = length(aStruct);
    adjList = cell(nrElements,1);
    % Create symetric adjaceny list of elements
    for i=1:nrElements-1
        for j=i+1:nrElements
            a = aStruct(i).voxel;
            b = aStruct(j).voxel;
            if ~isempty(intersect(a, b, 'rows')) 
                adjList{i}(end+1) = j;
                adjList{j}(end+1) = i;
            end
        end   
    end
    % Find CC
    components = bfs(1:nrElements, adjList);
    % Write all volumes as nodes to the skeleton according to CC
    for i=1:length(components)
        accStruct(i).voxel = unique(vertcat(aStruct(components{i}).voxel), 'rows');
        if isfield(aStruct, 'border');
            % Group CoM data according to CC
            border = vertcat(aStruct(components{i}).border);
            pre = vertcat(aStruct(components{i}).pre);
            post = vertcat(aStruct(components{i}).post);
            skel = addTree(skel, accStruct(i).voxel, [nameForTree num2str(i, '%.2i')], border, pre, post);
        else
            skel = addTree(skel, accStruct(i).voxel, [nameForTree num2str(i, '%.2i')]);
        end
    end

end

