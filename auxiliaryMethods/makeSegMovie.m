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

figure('Resize', 'off');
set(gcf,'NextPlot','replacechildren');
set(gcf,'Renderer','OpenGL');
if strcmp(computer('arch'), 'glnxa64')
    writerObj = VideoWriter(outputFile, 'Motion JPEG AVI');
elseif strcmp(computer('arch'), 'PCWIN64') || strcmp(computer('arch'), 'win64')
    writerObj = VideoWriter(outputFile, 'Uncompressed AVI');
else
    error('Please set up video codex compatible with your architecture here!')
end

writerObj.FrameRate = 4;
open(writerObj);
% Write each z-layer as one video frame
for f=1:size(raw,3)
    hold off;
    imshow(raw(:,:,f), [0 255]);
    hold on;
    temp = label2rgb(segmentation(:,:,f), cm);
    himage = imagesc(temp);
    caxis([-100 355]);
    set(himage, 'AlphaData', 0.05 );
    frame = getframe;
    if f == 1
        sizeFrame = size(frame);
    end
    writeVideo(writerObj,frame(1:sizeFrame(1),1:sizeFrame(2)));
end
close(writerObj);
close all;

end

