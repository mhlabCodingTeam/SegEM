function makeSkeletonMovies(param, raw)

% Settings & Figure Setup
colors = distinguishable_colors(length(param.skel));
figure;
set(gcf,'NextPlot','replacechildren');
set(gcf,'Renderer','OpenGL');
writerObj = VideoWriter([param.dataFolder param.figureSubfolder '/skeletonMovie.avi']);
writerObj.FrameRate = 4;
open(writerObj);
% Plot each frame raw data and skeletons & write  to video
for f=1:size(raw,3)
    hold off;
    imagesc(raw(:,:,f));
    colormap('gray');
    axis off;
    axis equal;
    caxis([-2 2]);
    hold on;
    for skel=1:length(param.skel)
        toPlot = param.skel{skel}.nodes(:,3) == f;
        if sum(toPlot)
            plot(param.skel{skel}.nodes(toPlot,2),param.skel{skel}.nodes(toPlot,1), 'x', 'Color', colors(skel,:), 'MarkerSize', 5, 'LineWidth', 2);
        end
    end
    drawnow;
    frame = getframe;
    %imwrite(frame.cdata, [param.dataFolder param.figureSubfolder '/skeletonFrame' num2str(f, '%.3i') '.tif']);
    writeVideo(writerObj,frame);
end
% Close everything
close(writerObj);
close all;
end

