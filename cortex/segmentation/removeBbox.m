function skel = removeBbox(skel)
    % Removes all skeletons with name containing 'bbox' from skeleton collection
    % This should not be necessary anymore at some point, was just still necessary due to not yet implemented Oxalis BBox feature

    toDel = zeros(length(skel),1);
    for i=1:length(skel)
        if strfind(skel{i}.name,'bbox')
            toDel(i) = 1;
        end
    end
    display(['Removing ' num2str(sum(toDel)) ' bounding box trees from skeleton collection.']);
    skel(toDel > 0) = [];

end
