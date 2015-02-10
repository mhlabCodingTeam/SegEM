function makeSegMovies( segmentation, raw)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

load('/home/mberning/code/segmentation/autoKLEE_colormap.mat');
autoKLEE_colormap = repmat(autoKLEE_colormap, 100, 1);

figure;
writerObj = VideoWriter('/home/mberning/Desktop/segMovie.avi');
writerObj.FrameRate = 4;
open(writerObj);
for f=1:size(raw,3)
    hold off;
    imshow(raw(:,:,f), [60 180]);
    hold on;
    temp = label2rgb(segmentation(:,:,f), autoKLEE_colormap);
    himage = imshow(temp, [60 180]);
    set(himage, 'AlphaData', 0.15 );
    if f == 1
        set(gcf,'NextPlot','replacechildren');
        set(gcf,'Renderer','OpenGL'); 
    end
    drawnow;
    writeVideo(writerObj,getframe(gca, [1 1 1000 1000]));
end
close(writerObj);
close all;

end

