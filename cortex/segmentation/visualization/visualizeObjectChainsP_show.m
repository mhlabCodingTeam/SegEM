function visualizeObjectChainsP_show( param, eval, se, skel )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

load(param.cmSource);
autoKLEE_colormap = repmat(autoKLEE_colormap, 100, 1);
views = {2, 3, [90,0]};

if ~exist([param.dataFolder param.figureSubfolder param.subfolder 'objChains/'], 'dir')
    mkdir([param.dataFolder param.figureSubfolder param.subfolder 'objChains/']);
end

for chain=1:length(skel)
    sk = eval.nodes{chain};
    ske = skel{chain}.edges;
    if size(ske,2) > 1 && size(ske,1) > 0
        objects = unique(se(sub2ind(size(se),sk(:,1),sk(:,2),sk(:,3))));
        objects(objects == 0) = [];
        f = figure('Renderer', 'OpenGL', 'Visible', 'off' );
        hold on;
        k = cell(length(objects),1);
        for i=1:length(objects)
            obj = se == objects(i);
            issf = isosurface(obj, .1);
            k{i} = patch(issf);
            set(k{i}, 'FaceColor', autoKLEE_colormap(i,:), 'EdgeColor', 'none');
        end
        for i=1:size(ske,1)
            plot3(sk([ske(i,1) ske(i,2)],2), sk([ske(i,1) ske(i,2)],1), sk([ske(i,1) ske(i,2)],3), '-r', 'LineWidth', 3);
        end    
        view(views{2});
        daspect([25 25 12]);
        %title(['Skelett (KNOSSOS ID): ' num2str(skel{chain}.thingID)], 'FontSize', 18);
        grid on;
        alpha(.7);
        xlim([1 384]);
        ylim([1 384]);
        zlim([1 384]);
        camlight('headlight');
        lighting phong;
        set(gca, 'XTickLabel', '');
        set(gca, 'YTickLabel', '');
        set(gca, 'ZTickLabel', '');
        saveas(gcf, [param.dataFolder param.figureSubfolder param.subfolder 'objChains/chain' num2str(chain, '%3.3i') '.png']);
%         set(f,'PaperPositionMode', 'manual', 'PaperUnits','centimeters', ...
%         'Paperposition',[1 1 28 20], 'PaperSize', [29.2 21])
%          drawnow;
% 
% 
%         print(f, '-dpdf', '-r300', [param.dataFolder param.figureSubfolder param.subfolder 'objChains/chain' num2str(chain, '%3.3i')]);
%         close all;
    end
    
end

end

