function newSkel = mergeTrees(skel1, skel2, name1, name2)
% Joins two skeletons into two trees in one skeleton, makes some basic settings (color etc)

	newSkel(1) = skel1;
	newSkel{1}.parameters.activeNode.id = '1'; % some inconstinencies in auxiliaryMethods parse vs. writeNml?
	newSkel{1}.thingID = 1; % renumber things
	newSkel{1}.name = name1;
	newSkel{1}.color = [1 0 0 1];
	newSkel{1}.commentsString = '';
	% Have to renumber ids of nodes of second skeleton to keep ids globally unique (why? is this nml standard?)
	maxNodeID1 =  max(skel1{1}.nodesNumDataAll(:,1));
	maxNodeID2 =  max(skel2{1}.nodesNumDataAll(:,1));
	maxNodeID = max(maxNodeID1,maxNodeID2);
	oldIDs = skel2{1}.nodesNumDataAll(:,1);
	replace = find(oldIDs <= maxNodeID1);
	newIDs = maxNodeID+1:maxNodeID+length(replace);
	skel2{1}.nodesNumDataAll(replace,1) = newIDs;
	% Finished renumbering, add skeleton now
	newSkel(2) = skel2;
	newSkel{2}.thingID = 2;
	newSkel{2}.name = name2;
	newSkel{2}.color = [0 1 0 1];
	newSkel{2}.commentsString = '';

end