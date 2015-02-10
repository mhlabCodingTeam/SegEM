function visualizeObjectChainsP_leftout( param, eval, se, skel, par1, par2 )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

load(param.cmSource);
autoKLEE_colormap = repmat(autoKLEE_colormap, 100, 1);
views = {2, 3, [90,0]};

if ~exist([param.dataFolder param.figureSubfolder param.subfolder 'objChains/'], 'dir')
    mkdir([param.dataFolder param.figureSubfolder param.subfolder 'objChains/']);
end

figure('Renderer', 'OpenGL', 'Visible', 'off' );
test = sum(eval.general(par1,par2).equivMatrixBinary) < 1;
k = cell(length(max(se(:))),1);
for i=1:max(se(:))
    if test(i)
        obj = se == i;
        issf = isosurface(obj, .1);
        k{i} = patch(issf);
        set(k{i}, 'FaceColor', autoKLEE_colormap(i,:), 'EdgeColor', 'none');
    end
    view(views{2});
    daspect([25 25 12]);
    grid on;
    alpha(.9);
    xlim([1 384]);
    ylim([1 384]);
    zlim([1 384]);
    camlight('headlight');
    lighting phong;
end
saveas(gcf, [param.dataFolder param.figureSubfolder param.subfolder 'objChains/leftout.fig']);
saveas(gcf, [param.dataFolder param.figureSubfolder param.subfolder 'objChains/leftout.tif']);
close all;

end

