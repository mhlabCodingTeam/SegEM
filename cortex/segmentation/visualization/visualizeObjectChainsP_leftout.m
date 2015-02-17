function visualizeObjectChainsP_leftout( param, eval, se, skel )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

% 100 unique colors, replicate a lot to make it work
cm = distinguishable_colors(100, [1 1 1]);
cm = repmat(cm, 100,1);
views = {2, 3, [90,0]};

if ~exist([param.outputFolder 'objChains' filesep], 'dir')
    mkdir([param.outputFolder 'objChains' filesep]);
end

figure('Renderer', 'OpenGL');
test = sum(eval.general.equivMatrixBinary) < 1;
k = cell(length(max(se(:))),1);
for i=1:max(se(:))
    if test(i)
        obj = se == i;
        issf = isosurface(obj, .1);
        k{i} = patch(issf);
        set(k{i}, 'FaceColor', cm(i,:), 'EdgeColor', 'none');
    end
end
view(views{2});
daspect([25 25 12]);
grid on;
alpha(.4);
xlim([1 size(se,1)]);
ylim([1 size(se,2)]);
zlim([1 size(se,3)]);
camlight('headlight');
lighting phong;
saveas(gcf, [param.outputFolder 'objChains' filesep 'leftout.fig']);
saveas(gcf, [param.outputFolder 'objChains' filesep 'leftout.tif']);
close all;

end

