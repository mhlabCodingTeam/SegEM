function contactDetectionCortex(p, skeleton1, skeleton2, outputFile)
    % Pass two nml filenames which are to be contact detected and one output folder
    % Modified Benjamins gallery code (quite a bit)

    % Extract relevant stuff from parameter struct to avoid long multi-level indexing
    pCube = p.local(:);
    bboxBig = {pCube(:).bboxBig};
    bboxSmall = {pCube(:).bboxSmall};

    % Weird format to supress output, gets annoying after a while
    skel1 = parseNml(skeleton1);
    skel2 = parseNml(skeleton2);
    skel = mergeTrees(skel1, skel2, 'pre', 'post');

    % Find all linear indices of local cubes (in parameter struct) that are traversed by either skeleton
    nodes = [skel1{1}.nodes(:,1:3); skel2{1}.nodes(:,1:3)];
    cubeCoords = zeros(size(nodes,1),1);
    for i=1:size(nodes,1)
        idx = find(cellfun(@(x)(all([nodes(i,:)'>x(:,1); nodes(i,:)'<x(:,2)])), bboxSmall));
        if isempty(idx)
            cubeCoords(i) = 0;
        else
            cubeCoords(i) = idx;
        end
    end
    uniqueCubeCoords = unique(cubeCoords, 'rows');
    uniqueCubeCoords(uniqueCubeCoords == 0) = [];

    % Create spherical structuring element for morphological operations
    rT = 2;
    [x,y,z] = meshgrid(-rT:rT,-rT:rT,-rT:rT);
    se = (x/rT).^2 + (y/rT).^2 + (z/rT).^2 <= 1;
    
    % Set voxel dimension in nm for calculation of distances
    voxSize = [11.24 11.24 28];
    % counter
    contactNumber = 0;
    mergerNumber = 0;
    merger = [];
    contact = [];
    for i = 1:size(uniqueCubeCoords,1)
        % Bounding box of current unique cube including overlap (hardcoded for 64 border)
        lowerLimit = bboxBig{uniqueCubeCoords(i)}(:,1)';
        upperLimit = bboxBig{uniqueCubeCoords(i)}(:,2)';
        % find all nodes from skeletons that lie in the same cube including overlap(!)
        nodeIdx1 = all(bsxfun(@le, skel{1}.nodes(:,1:3), upperLimit) & bsxfun(@ge, skel{1}.nodes(:,1:3), lowerLimit),2);
        nodeIdx2 = all(bsxfun(@le, skel{2}.nodes(:,1:3), upperLimit) & bsxfun(@ge, skel{2}.nodes(:,1:3), lowerLimit),2);
        % Continue only if nodes in cube (including overlap) in both skeletons is present 
        if any(nodeIdx1) && any(nodeIdx2)
            % all nodes for this cube from both skeletons
            skel1nodes = skel{1}.nodes(nodeIdx1,1:3);
            skel2nodes = skel{2}.nodes(nodeIdx2,1:3);
            skel1nodesLocal = bsxfun(@minus, skel1nodes, lowerLimit-1);
            skel2nodesLocal = bsxfun(@minus, skel2nodes, lowerLimit-1);
            % read local segmentation from disk
            load(pCube(uniqueCubeCoords(i)).segFile);
            % get all local segmentation IDs of the nodes in the cube & vector of unique values
            segIds1 = seg(sub2ind(size(seg),skel1nodesLocal(:,1),skel1nodesLocal(:,2),skel1nodesLocal(:,3)));
            uniqueSegIds1 = nonzeros(unique(segIds1));
            segIds2 = seg(sub2ind(size(seg),skel2nodesLocal(:,1),skel2nodesLocal(:,2),skel2nodesLocal(:,3)));
            uniqueSegIds2 = nonzeros(unique(segIds2));
            % Detect merger: winner takes all according to number of nodes in segment/supervoxel
            mergeSegId = intersect(uniqueSegIds1, uniqueSegIds2); 
            if ~isempty(mergeSegId);
                display([num2str(uniqueCubeCoords(i,:), '%.2i') ' - Merger detected, ID(s): ' num2str(mergeSegId')]);
                for j=1:length(mergeSegId)
                    % Save some info about each merger
                    mergerNumber = mergerNumber + 1;
                    merger(mergerNumber).cubeId = uniqueCubeCoords(i,:);
                    merger(mergerNumber).segIdMerger = mergeSegId(j);
                    temp = regionprops(seg == mergeSegId(j), 'PixelList');
                    if length(temp) > 1 % Quick check to see if merger object is continous (should be the case with watershed segmentation)
                        error('Merger object split into pieces :)');
                    end
                    merger(mergerNumber).voxel = bsxfun(@plus,temp.PixelList(:,[2 1 3]),lowerLimit-1);
                    merger(mergerNumber).nodeCounts(1) = sum(segIds1 == mergeSegId(j));
                    merger(mergerNumber).nodeCounts(2) = sum(segIds2 == mergeSegId(j));
                    % Winner takes all, nobody takes anything in case of tie
                    if merger(mergerNumber).nodeCounts(1) > merger(mergerNumber).nodeCounts(2)
                        uniqueSegIds2(uniqueSegIds2 == mergeSegId(j)) = [];
                    elseif merger(mergerNumber).nodeCounts(2) > merger(mergerNumber).nodeCounts(1)
                        uniqueSegIds1(uniqueSegIds1 == mergeSegId(j)) = [];
                    else
                        uniqueSegIds1(uniqueSegIds1 == mergeSegId(j)) = [];
                        uniqueSegIds2(uniqueSegIds2 == mergeSegId(j)) = [];
                    end
                end	
            end
            % Find contact area in segmentation
            cube1 = ismember(seg,uniqueSegIds1);
            cube2 = ismember(seg,uniqueSegIds2);
            props1 = regionprops(cube1, {'Centroid'});
            props2 = regionprops(cube2, {'Centroid'});
            contactCube = imdilate(cube1, se) & imdilate(cube2, se);
            contactCube = imclose(contactCube, ones(10,10,10));
            props = regionprops(contactCube, {'PixelList' 'Centroid'});
            for j=1:length(props)
                % node threshold of 10
                if size(props(j).PixelList,1) > 10
                    %display([num2str(uniqueCubeCoords(i,:), '%.2i,%.2i,%.2i') ' - Contact detected']);
                    % Save some info about each contact
                    contactNumber = contactNumber + 1;
                    contact(contactNumber).cubeId = uniqueCubeCoords(i,:);
                    contact(contactNumber).voxel = bsxfun(@plus,props(j).PixelList(:,[2 1 3]),lowerLimit-1);
                    % CoM of border region
                    contact(contactNumber).border.centroid = props(j).Centroid([2 1 3]) + lowerLimit - 1;
                    % Nodes of skeletons closest to CoM of border region
                    [distToBorder, idx] = min(pdist2(bsxfun(@times,vertcat(props1(:).Centroid),voxSize),bsxfun(@times,props(j).Centroid,voxSize)));
                    contact(contactNumber).pre.centroid = props1(idx).Centroid([2 1 3]) + lowerLimit - 1;		
                    contact(contactNumber).pre.distance = distToBorder;
                    [distToBorder, idx] = min(pdist2(bsxfun(@times,vertcat(props2(:).Centroid),voxSize),bsxfun(@times,props(j).Centroid,voxSize)));
                    contact(contactNumber).post.centroid = props2(idx).Centroid([2 1 3]) + lowerLimit - 1;
                    contact(contactNumber).post.distance = distToBorder;
                end
            end
        end
    end

    if ~isempty(contact)
        [skel, contact] = accumulateOverCubeBorders(skel, contact, 'Contact ID : ');
    end

    if ~isempty(merger)
        [skel, merger] = accumulateOverCubeBorders(skel, merger, 'Merger ID : ');
    end

    writeNmlOld(outputFile, skel);

end

