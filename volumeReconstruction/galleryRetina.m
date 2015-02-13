function galleryRetina( skelPath, skelFile, outputPath, seg )
% Collect segments along given skeleton and calculate isosurfaces

% Read .nml and 
skel_data = parseNml([skelPath skelFile]);

% for each node, find cube in which it lays so the cubes data can be used for
% several nodes
nodeData.nodes = skel_data{1,1}.nodes(:,1:3);
nodeData.cubeCoords = zeros(1,size(nodeData.nodes,2));
for i = 1 : size(nodeData.nodes,1)
   nodeData.cubeCoords(i,:) = floor(( nodeData.nodes(i,:) - 1) / 128 ); %from readKnossosRoi ...  overlap of 128!
   nodeData.flag(i) = 0;
end

% group nodes that lie in the same cube
groupCount = 0;
for i = 1 : size(nodeData.nodes,1)
    if(nodeData.flag(i)==0)
	groupCount = groupCount+1;
	groupedNodes{1,groupCount}.nodes = nodeData.nodes(i,:);
	groupedNodes{1,groupCount}.cubeCoords = nodeData.cubeCoords(i,:);
	if(i<size(nodeData.nodes,1))            
	    for j = i+1 : size(nodeData.nodes,1)
		if(nodeData.cubeCoords(i,:) == nodeData.cubeCoords(j,:))
		    groupedNodes{1,groupCount}.nodes = [groupedNodes{1,groupCount}.nodes ; nodeData.nodes(j,:)];
		    nodeData.flag(j) = 1;
		end
	    end
	end
    end
end

% for each cube get data and write 1 into result cube for the voxels 
% belonging to one of the segments of the nodes lying in the cube 
for i = 1 : size(groupedNodes,2)
	%read cube
	if all(groupedNodes{i}.cubeCoords > [7 3 1]) && all(groupedNodes{i}.cubeCoords < [30 39 42])
	    cube = readKnossosCube(seg.root, seg.prefix, groupedNodes{i}.cubeCoords, 'uint16=>uint16', '', 'raw', 256);
	    %get the color values of the nodes in the cube
	    segIds = zeros(1,size(groupedNodes{i}.nodes,1));
	    zeroOfCube = groupedNodes{i}.cubeCoords * 128 + 1;
	    zeroOfCube = zeroOfCube-64;
	    for j = 1 : size(groupedNodes{i}.nodes,1) 
		rel_coords = groupedNodes{i}.nodes(j,:) - zeroOfCube(1,:); % point in cube = actual point - zero of cube
		segIds(1,j) = cube(rel_coords(1),rel_coords(2),rel_coords(3)); 
	    end   
	    segIds(segIds == 0) = []; %delete the zeros no neuron has color black
	    counts = histc(segIds,unique(segIds));
	    segIds = unique(segIds);
	    segIds(counts < 1) = [];
	    if ~isempty(segIds)
	    for k = 1 : size(segIds,2)
		cube(cube == segIds(k)) = NaN;
	    end
	    cube(~isnan(cube)) = 0;
	    cube(isnan(cube)) = 1;
	    cube = imclose(cube, ones([3,3,3]));
	    cube = padarray(cube, [1 1 1]);
	    cube = smooth3(cube, 'gaussian', 5, 2);
	    issfs{i} = isosurface(cube, .5);
	    if ~isempty(issfs{i}.vertices)
		    issfs{i} = reducepatch(issfs{i}, .01);
		    issfs{i}.vertices(:,[1 2]) = issfs{i}.vertices(:,[2 1]); 			    
		    issfs{i}.vertices = issfs{i}.vertices + repmat(zeroOfCube - [1 1 1],size(issfs{i}.vertices,1),1);
		    issfs{i}.vertices = issfs{i}.vertices .* repmat([12 12 25],size(issfs{i}.vertices,1),1);
	    end
	    end
	end
end
if exist('issfs', 'var')
	idx = zeros(length(issfs),1);
	for i=1:length(issfs)
		if isempty(issfs{i}) || isempty(issfs{i}.vertices)
			idx(i) = 1;
		end
	end
	issfs(find(idx)) = [];		
	% Save
	skel_data{1}.nodes(:,1:3) = skel_data{1}.nodes(:,1:3) .* repmat([12 12 25], size(skel_data{1}.nodes,1), 1);
	exportSurfaceToAmira(issfs, [outputPath skelFile(1:end-4) '.issf']);
	%convertKnossosNmlToHoc2(skel_data, [outputPath files(id).name(1:end-4)], 0, 1, 0, 0, [1 1 1]);
	clear groupedNodes issfs;
end

end

