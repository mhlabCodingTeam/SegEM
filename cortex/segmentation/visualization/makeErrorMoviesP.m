function makeErrorMoviesP( param, eval, segmentation, raw)

colors = {'or' 'og' 'ob' 'oy' 'oc' 'om'};

for errorIdx=1:length(eval.merge.obj)
    figure;
    writerObj = VideoWriter([param.outputFolder 'errorMovie' num2str(errorIdx, '%.3i')]);
    writerObj.FrameRate = 4;
    open(writerObj);
    for f=1:size(raw,3)
        hold off;
        imshow(raw(:,:,f), [60 180]);
        hold on;
        temp = single(segmentation(:,:,f));
        temp(temp == eval.merge.idx(errorIdx)) = -1;
        temp(temp ~= -1) = 0;
        temp(temp == -1) = 255;
        temp = uint8(temp);
        temp = label2rgb(temp, 'jet');
        str = [];
        for m=1:length(eval.merge.obj{errorIdx})
            str = [str num2str(eval.merge.obj{errorIdx}(m)) ' '];
            if sum(eval.nodes{eval.merge.obj{errorIdx}(m)}(:,3) == f)
                idNodes = find(eval.nodes{eval.merge.obj{errorIdx}(m)}(:,3) == f);
                plot(eval.nodes{eval.merge.obj{errorIdx}(m)}(idNodes,2), eval.nodes{eval.merge.obj{errorIdx}(m)}(idNodes,1), colors{rem(m,6)+1}, 'LineWidth', 3);
            end
        end
        himage = imshow(temp);
        set(himage, 'AlphaData', 0.15 );
        if f == 1
            set(gcf,'NextPlot','replacechildren');
            set(gcf,'Renderer','OpenGL'); 
        end
        title(['Skeletons (KNOSSOS ID): ' str]);
        drawnow;
        writeVideo(writerObj,getframe(gca, [1 1 384 384]));
    end
    close(writerObj);
    close all;
end

end

