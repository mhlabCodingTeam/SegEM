function makeSegMovie( segmentation, raw, outputFile )
% make video of raw data + seg video

% Relabel segmentation to continous IDs starting at 1
sizeCube = size(segmentation);
segmentation = segmentation(:);
[localIds, ~, n] = unique(segmentation);
nrUniqueIds = length(localIds) - 1;
newIds = [0 1:nrUniqueIds];
segmentation = newIds(n);
segmentation = reshape(segmentation, sizeCube);
% Create colormap (with bg set to white and black to avoid those)
cm = distinguishable_colors(length(unique(segmentation(:)))-1, [0 0 0; 1 1 1]);
% Add black for bg
cm = [0 0 0; cm];

figure;
set(gcf,'NextPlot','replacechildren');
set(gcf,'Renderer','OpenGL');
writerObj = VideoWriter(outputFile);
writerObj.FrameRate = 4;
open(writerObj);
% Write each z-layer as one video frame
for f=1:size(raw,3)
    hold off;
    imshow(raw(:,:,f), [60 180]);
    hold on;
    temp = label2rgb(segmentation(:,:,f), cm);
    himage = imshow(temp, [60 180]);
    set(himage, 'AlphaData', 0.15 );
    frame = getframe;
    writeVideo(writerObj,frame);
end
close(writerObj);
close all;

end

