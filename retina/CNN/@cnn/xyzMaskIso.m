function [target, mask] = xyzMaskIso( cnet, currentTrace)
%mask = cnet.xyzMask(currentTrace) Calculate Masks for three affinity maps in
%output layer and return in cell array
target = cell(3,1);
mask = cell(3,1);

target{1} = zeros(size(currentTrace)-[0 1 0]);
for i=1:size(currentTrace,2)-1
    target{1}(:,i,:) = ((currentTrace(:,i,:) == currentTrace(:,i+1,:) & currentTrace(:,i,:) ~= 0) - 0.5) * 2;
end
target{1}(1,:,:) = [];
target{1}(:,:,1) = [];

% Create mask with one target calssified as not connected in each dimension
mask{1} = currentTrace(2:end,2:end,2:end) ~= 0;
mask{1} = mask{1} | ...
    cat(2, zeros(size(mask{1},1), 1, size(mask{1},3)), mask{1}(:,1:end-1,:));

% Expand border one pixel in both directions in all 3 dimensions (in each
% loop)
for i=1:cnet.isoBorder
    mask{1} = mask{1} | cat(1, zeros(1, size(mask{1},2), size(mask{1},3)), mask{1}(1:end-1,:,:)) ...
                      | cat(1, mask{1}(2:end,:,:), zeros(1, size(mask{1},2), size(mask{1},3))) ...
                      | cat(2, zeros(size(mask{1},1), 1, size(mask{1},3)), mask{1}(:,1:end-1,:)) ...
                      | cat(2, mask{1}(:,2:end,:), zeros(size(mask{1},1), 1, size(mask{1},3))) ...
                      | cat(3, mask{1}(:,:,2:end), zeros(size(mask{1},1), size(mask{1},2), 1)) ...
                      | cat(3, zeros(size(mask{1},1), size(mask{1},2), 1), mask{1}(:,:,1:end-1));
end

target{2} = zeros(size(currentTrace)-[1 0 0]);
for i=1:size(currentTrace,1)-1
    target{2}(i,:,:) = ((currentTrace(i,:,:) == currentTrace(i+1,:,:) & currentTrace(i,:,:) ~= 0) - 0.5) * 2;
end
target{2}(:,1,:) = [];
target{2}(:,:,1) = [];

% Create mask with one target calssified as not connected in each dimension
mask{2} = currentTrace(2:end,2:end,2:end) ~= 0;
mask{2} = mask{2} | ...
	cat(1, zeros(1, size(mask{2},2), size(mask{2},3)), mask{2}(1:end-1,:,:));

% Expand border one pixel in both directions in all 3 dimensions (in each
% loop)
for i=1:cnet.isoBorder
    mask{2} = mask{2} | cat(1, zeros(1, size(mask{2},2), size(mask{2},3)), mask{2}(1:end-1,:,:)) ...
                      | cat(1, mask{2}(2:end,:,:), zeros(1, size(mask{2},2), size(mask{2},3))) ...
                      | cat(2, zeros(size(mask{2},1), 1, size(mask{2},3)), mask{2}(:,1:end-1,:)) ...
                      | cat(2, mask{2}(:,2:end,:), zeros(size(mask{2},1), 1, size(mask{2},3))) ...
                      | cat(3, mask{2}(:,:,2:end), zeros(size(mask{2},1), size(mask{2},2), 1)) ...
                      | cat(3, zeros(size(mask{2},1), size(mask{2},2), 1), mask{2}(:,:,1:end-1));
end

target{3} = zeros(size(currentTrace)-[0 0 1]);
for i=1:size(currentTrace,3)-1
    target{3}(:,:,i) = ((currentTrace(:,:,i) == currentTrace(:,:,i+1) & currentTrace(:,:,i) ~= 0) - 0.5) * 2;
end
target{3}(1,:,:) = [];
target{3}(:,1,:) = [];

% Create mask with one target calssified as not connected in each dimension
mask{3} = currentTrace(2:end,2:end,2:end) ~= 0;
mask{3} = mask{3} | ...
	cat(3, zeros(size(mask{3},1), size(mask{3},2), 1), mask{3}(:,:,1:end-1));

% Expand border one pixel in both directions in all 3 dimensions (in each
% loop)
for i=1:cnet.isoBorder
    mask{3} = mask{3} | cat(1, zeros(1, size(mask{3},2), size(mask{3},3)), mask{3}(1:end-1,:,:)) ...
                      | cat(1, mask{3}(2:end,:,:), zeros(1, size(mask{3},2), size(mask{3},3))) ...
                      | cat(2, zeros(size(mask{3},1), 1, size(mask{3},3)), mask{3}(:,1:end-1,:)) ...
                      | cat(2, mask{3}(:,2:end,:), zeros(size(mask{3},1), 1, size(mask{3},3))) ...
                      | cat(3, mask{3}(:,:,2:end), zeros(size(mask{3},1), size(mask{3},2), 1)) ...
                      | cat(3, zeros(size(mask{3},1), size(mask{3},2), 1), mask{3}(:,:,1:end-1));
end

% Maybe update cnet class at some point (after making sure isotropic borders will
% be only approach) to only create one mask for all three targets

end
