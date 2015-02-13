function components = bfs(idx,adjacency_list)

components ={};
k = 1;
nonvisited = 1:length(idx);

while ~isempty(nonvisited)
    components{k,1} = idx(nonvisited(1));
    l1 = size(components{k,1},2);
    components{k,1}=horzcat(components{k,1},adjacency_list{nonvisited(1)});
    l2 = size(components{k,1},2);
    nonvisited(1)=[];
    while l1~=l2
        v=[];
        for j=l1+1:l2
            index = find(idx==(components{k,1}(j)));
            v=[v,adjacency_list{index}];
            nonvisited(nonvisited==index)=[];
        end
        l1 = l2;
        v = intersect(v,idx(nonvisited));
        components{k,1}=horzcat(components{k,1},v);
        l2 = size(components{k,1},2);
    end
    k = k+1;
end

end
