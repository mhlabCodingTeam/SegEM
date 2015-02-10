function [k, issfs] = plotIsosurfaces( kl_stack, colors )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
cellLabel = unique(kl_stack);
cellLabel(cellLabel == 0) = [];
k = cell(size(cellLabel));
for i=1:length(cellLabel)
   singleCellStack = kl_stack == cellLabel(i);
   issfs{i} = isosurface(singleCellStack, .1);
   k{i} = patch(issfs{i});
   set(k{i}, 'FaceColor', colors(mod(i-1,31)+1,:), 'EdgeColor', 'none');
end

end
