function [target, mask] = xyMask( ~, currentTrace )
%mask = cnet.xyzMask(currentTrace) Calculate Masks for three affinity maps in
%output layer and return in cell array
target = cell(2,1);
mask = cell(2,1);

target{1} = zeros(size(currentTrace)-[0 1]);
for i=1:size(currentTrace,2)-1
    target{1}(:,i) = ((currentTrace(:,i) == currentTrace(:,i+1) & currentTrace(:,i) ~= 0) - 0.5) * 2;
end
target{1}(1,:) = [];

mask{1} = currentTrace(2:end,2:end) ~= 0;
mask{1} = mask{1} | cat(2, zeros(size(mask{1},1),1), mask{1}(:,1:end-1));

target{2} = zeros(size(currentTrace)-[1 0]);
for i=1:size(currentTrace,1)-1
    target{2}(i,:) = ((currentTrace(i,:) == currentTrace(i+1,:) & currentTrace(i,:) ~= 0) - 0.5) * 2;
end
target{2}(:,1) = [];

mask{2} = currentTrace(2:end,2:end) ~= 0;
mask{2} = mask{2} | cat(1, zeros(1, size(mask{2},2)), mask{2}(1:end-1,:));

end

 