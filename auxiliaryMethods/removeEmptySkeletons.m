function skel = removeEmptySkeletons( skel )
% Remove empty trees from skeleton

toDel = zeros(length(skel),1);
for i=1:length(skel)
    if isempty(skel{i}.nodes) || size(skel{i}.nodes,1) == 0
        toDel(i) = 1;
    end
end
if any(toDel)
    skel = skel(~toDel);
end

end
