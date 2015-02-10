function makeSegMovie( segmentation, raw, outputFile )
% make video of raw data + seg video

% Relabel segmentation to continous IDs starting at 1
sizeCube = size(segmentation);
segmentation = segmentation(:);
[localIds, ~, n] = unique(segmentation);
nrUniqueIds = length(localIds) - 1;
newIds = 0:1:nrUniqueIds;
segmentation = newIds(n);
segmentation = reshape(segmentation, sizeCube);

% Create colormap (with bg set to white and black to avoid those)
cm = distinguishable_colors(length(unique(segmentation(:)))-1, [0 0 0; 1 1 1]);
% Add black for bg
cm = [0 0 0; cm];

% Which raw data slices to show for each dimension
slices = {[1] [1] [1]};

% Plot everything
figure;
hold on;
plotIsosurfaces(segmentation, cm);
plotOriginalData(raw, slices);
xlim([1 size(raw,1)]);
ylim([1 size(raw,2)]);
zlim([1 size(raw,3)]);    
daspect([28 28 11.24]);
axis off;
view(110,25);
camlight('headlight');
lighting phong;
set(gcf, 'Color', 'w');
    
set(gcf,'PaperPositionMode', 'manual', 'PaperUnits','centimeters', ...
'Paperposition',[1 1 28 20], 'PaperSize', [29.2 21])
drawnow;
print(gcf, '-dpdf', '-r300', outputFile);


end

