function skel = addTree(skel, nodeCoord, name, border, pre, post)
% Quick fix to be able to add single node trees to an skeleton 

nrNodes = size(nodeCoord,1);
maxNodeID = max(skel{end}.nodesNumDataAll(:,1))+1;
% subsample contact/merger visualizatiosn at factor 10 if more than 500 nodes
if nrNodes > 500 && nrNodes <= 5000
	skel{end+1}.name = [name ' (10x subsampling) of size ' num2str(nrNodes)];
	nodeCoord = nodeCoord(1:10:end,1:3);
	nrNodes = size(nodeCoord,1);
elseif nrNodes > 5000
	skel{end+1}.name = [name ' (subsampling down to 5000 nodes) of size ' num2str(nrNodes)];
	idx = randperm(nrNodes);
	idx = idx(1:5000);
	nodeCoord = nodeCoord(idx,1:3);
	nrNodes = size(nodeCoord,1);
else
	skel{end+1}.name = [name ' (no subsampling) of size ' num2str(nrNodes)];
end
% Create a basic tree to skeleton (has to be useable by writeNml later)
skel{end}.thingID = length(skel);
skel{end}.color = [0 0 1 1];
skel{end}.commentsString = '';
skel{end}.nodesNumDataAll = zeros(nrNodes, 8);
skel{end}.nodesNumDataAll(:,3) = nodeCoord(:,1);
skel{end}.nodesNumDataAll(:,4) = nodeCoord(:,2);
skel{end}.nodesNumDataAll(:,5) = nodeCoord(:,3);
skel{end}.nodesNumDataAll(:,1) = maxNodeID:maxNodeID+nrNodes-1;
skel{end}.nodesNumDataAll(:,2) = 1.5*ones(nrNodes,1);
% No comments for all the volume label nodes (see loop below for CoM nodes)
for i=1:nrNodes
    skel{end}.nodesAsStruct{i}.id = maxNodeID+i-1;
    skel{end}.nodesAsStruct{i}.comment = '';
end
% Connect all nodes to the one with the next ID (otherwise oxalis will split into different trees)
for i=1:nrNodes-1;
    skel{end}.edges(i,:) = [i i+1];
end
% Add CoM nodes to skeleton
if nargin > 3
	% Add three commented nodes in center of mass of pre,post and border volumes
	borderCoM = mean(vertcat(border(:).centroid),1);
	skel{end}.nodesNumDataAll(end+1,:) = [maxNodeID+nrNodes 1.5 round(borderCoM) 0 0 0];
	skel{end}.nodesAsStruct{1+nrNodes}.id = num2str(maxNodeID+nrNodes);
	skel{end}.nodesAsStruct{1+nrNodes}.comment = 'CoM border';
	[preDistCoM, idx] = min([pre(:).distance]);
	skel{end}.nodesNumDataAll(end+1,:) = [maxNodeID+nrNodes+1 1.5 round(pre(idx).centroid) 0 0 0];
	skel{end}.nodesAsStruct{1+nrNodes+1}.id = num2str(maxNodeID+nrNodes+1);
	skel{end}.nodesAsStruct{1+nrNodes+1}.comment = ['CoM presynaptic, distance: ' num2str(preDistCoM) 'nm'];
	[postDistCoM, idx] = min([post(:).distance]);
	skel{end}.nodesNumDataAll(end+1,:) = [maxNodeID+nrNodes+2 1.5 round(post(idx).centroid) 0 0 0];
	skel{end}.nodesAsStruct{1+nrNodes+2}.id = num2str(maxNodeID+nrNodes+2);
	skel{end}.nodesAsStruct{1+nrNodes+2}.comment = ['CoM postsynaptic, distance: ' num2str(postDistCoM) 'nm'];
	% Trees need to be connected in order to not be splitted by oxalis
	skel{end}.edges(end+1,:) = [nrNodes nrNodes+1];
	skel{end}.edges(end+1,:) = [nrNodes+1 nrNodes+2];
	skel{end}.edges(end+1,:) = [nrNodes+1 nrNodes+3];
end

end
