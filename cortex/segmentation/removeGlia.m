function skel = removeGlia(skel)
% Removes all skeletons with comment glia from skeleton collection

    toDel = zeros(length(skel),1);
    for i=1:length(skel)
        for j=1:length(skel{i}.nodesAsStruct)
            if ~isempty(strfind(skel{i}.nodesAsStruct{j}.comment,'glia')) || ~isempty(strfind(skel{i}.nodesAsStruct{j}.comment,'Glia'));
                toDel(i) = 1;
            end
        end
    end
    display(['Removing ' num2str(sum(toDel)) ' glia cells from skeleton collection.']);
    skel(toDel > 0) = [];

end

