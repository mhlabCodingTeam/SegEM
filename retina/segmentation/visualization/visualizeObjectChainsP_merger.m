function visualizeObjectChainsP_merger( param, eval, se, skel, par1, par2 )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

load(param.cmSource);
autoKLEE_colormap = repmat(autoKLEE_colormap, 10, 1);
views = {2, 3, [90,0]};

if ~exist([param.dataFolder param.figureSubfolder param.subfolder 'objChains/'], 'dir')
    mkdir([param.dataFolder param.figureSubfolder param.subfolder 'objChains/']);
end

for merger=1:length(eval.merge(par1,par2).obj)
    f = figure('Renderer', 'OpenGL');
    for c=1:length(eval.merge(par1,par2).obj{merger})
        chain = eval.merge(par1,par2).obj{merger}(c);
        sk = eval.nodes{chain};
        ske = skel{chain}.edges;
%         objects = unique(se(sub2ind(size(se),sk(:,1),sk(:,2),sk(:,3))));
%         objects(objects == 0) = [];
        objects = eval.merge(par1,par2).idx(merger);
        hold on;
        for i=1:size(ske,1)
            plot3(sk([ske(i,1) ske(i,2)],2), sk([ske(i,1) ske(i,2)],1), sk([ske(i,1) ske(i,2)],3), '-', 'Color', autoKLEE_colormap(c,:), 'LineWidth', 3);
        end
        k = cell(length(objects),1);
        for i=1:length(objects)
            obj = smooth3(se == objects(i), 'gaussian', 9, 2);
            issf = isosurface(obj, .1);
            k{i} = patch(issf);
            if objects(i) == eval.merge(par1,par2).idx(merger)
                set(k{i}, 'FaceColor', 'r', 'EdgeColor', 'none');
                if c ~= 1
                    set(k{i}, 'Visible', 'off');
                end
            else
                set(k{i}, 'FaceColor', 'g', 'EdgeColor', 'none');
            end
        end
        view(views{2});
        daspect([25 25 12]);
        grid on;
        xlim([1 384]);
        ylim([1 384]);
        zlim([1 384]);
        alpha(.4);
        camlight('headlight');
        lighting phong;
    end
    saveas(f, [param.dataFolder param.figureSubfolder param.subfolder 'objChains/merger' num2str(merger, '%3.3i') '.tif']);
    saveas(f, [param.dataFolder param.figureSubfolder param.subfolder 'objChains/merger' num2str(merger, '%3.3i') '.fig']);
    close all;
end

end

