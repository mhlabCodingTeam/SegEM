function makeErrorMovies( raw, segmentation, nodes, split, merge, iRange, jRange, kRange, viewErrors, viewSplits, colormap, outputDir )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

colors = {'or' 'og' 'ob' 'oy' 'oc' 'om'};

for i=iRange
    for j=jRange
        for k=kRange
%             for errorIdx=1:length(merge(i,j,k).obj)
%                 writerObj = VideoWriter([outputDir 'error' num2str(errorIdx, '%3.3i') '.avi']);
%                 writerObj.FrameRate = 4;
%                 open(writerObj);
                for f=1:384
                    hold off;
                    imshow(raw(:,:,f));
                    hold on;
                    if ~viewErrors
                        temp = label2rgb(segmentation{i,j,k}(:,:,f), repmat(colormap,100,1));
                    else
                        if viewSplits
                            % implementation of split viewing to be done
                        else
                            temp = single(segmentation{i,j,k}(:,:,f));
                            temp(temp == merge(i,j,k).idx(errorIdx)) = -1;
                            temp(temp ~= -1) = 0;
                            temp(temp == -1) = 255;
                            temp = uint8(temp);
                            temp = label2rgb(temp, 'jet');
                            for m=1:length(merge(i,j,k).obj{errorIdx})
                                if sum(nodes{merge(i,j,k).obj{errorIdx}(m)}(:,3) == f)
                                    idNodes = find(nodes{merge(i,j,k).obj{errorIdx}(m)}(:,3) == f);
                                    plot(nodes{merge(i,j,k).obj{errorIdx}(m)}(idNodes,2), nodes{merge(i,j,k).obj{errorIdx}(m)}(idNodes,1), colors{rem(m,6)+1}, 'LineWidth', 3);
                                end
                            end
                        end
                    end
%                     himage = imshow(temp);
%                     set(himage, 'AlphaData', 0.2 );
%                     title([num2str(i) num2str(j) num2str(k) ': ' num2str(errorIdx, '%3.3i')]);
                    if f == 1
                        set(gcf,'NextPlot','replacechildren');
                        set(gcf,'Renderer','OpenGL'); 
                    end
                    drawnow;
%                     writeVideo(writerObj,getframe(gca, [0 0 384 384]));
%                     pause(.2);
                    saveas(gcf, [outputDir num2str(f, '%3.0i') '.pdf']);
                end
%                 close(writerObj);
%             end
        end
    end
end

end

