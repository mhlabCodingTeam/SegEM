function totalLength = getPathLength( skeleton )

if isempty(skeleton{1}.parameters)
    voxelsize= [1 1 1];
else
    voxelsize = [str2double(skeleton{1}.parameters.scale.x) ...
        str2double(skeleton{1}.parameters.scale.y) ...
        str2double(skeleton{1}.parameters.scale.z)];
end

totalLength = 0;
for sk=1:length(skeleton)
    if ~isempty(skeleton{sk})
        if size(skeleton{sk}.edges,2) == 1 
            % skeleton edges seem to switch dimensionality if only
            % one edge is present
            edgePos = skeleton{sk}.nodes(skeleton{sk}.edges(:,1)',1:3);
            totalLength = totalLength + norm((edgePos(1,:)-edgePos(2,:)).*voxelsize);
        else
            for ed=1:size(skeleton{sk}.edges,1)
                edgePos = skeleton{sk}.nodes(skeleton{sk}.edges(ed,:),1:3);
                totalLength = totalLength + norm((edgePos(1,:)-edgePos(2,:)).*voxelsize);
            end
        end
    end
end

end