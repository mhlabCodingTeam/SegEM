function visualizeOverview_4( param,paramTest )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here            
load(param.cmSource);
if ~exist([param.dataFolder param.figureSubfolder '/'], 'dir')
    mkdir([param.dataFolder param.figureSubfolder '/']);
end
display('Overview Training vs. Test Comparison');
figure('position', [1 1 1600 785]);
hold on;
[a,b,c] = plotParam(param, autoKLEE_colormap(1,:));
[d,e,f] = plotParam(paramTest, autoKLEE_colormap(2,:));
xlabel('average distance between merger [nm]');
ylabel('average distance between splits [nm]');
zlabel('# objects');
grid on;
legend([a b c d e f], 'training node threshold 1', 'training node threshold 2', 'training node threshold 3' ...
    , 'test node threshold 1', 'test node threshold 2', 'test node threshold 3');
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
saveas(gcf, [param.dataFolder param.figureSubfolder '/overviewComparison.fig']);

function [u,v,w] = plotParam(param, color)
    marker = {'+' 'o' 'x'};  
    for r=1:2
        for algo=2
            aa = load([param.dataFolder param.outputSubfolder  param.affMaps(1).name filesep 'seg' num2str(r) '-' num2str(algo) '.mat'], 'v');
            eval1 = evaluateSeg(aa.v, param.skel, 1);
            eval2 = evaluateSeg(aa.v, param.skel, 2);
            eval3 = evaluateSeg(aa.v, param.skel, 3);
            for i=1:size(aa.v,1)
                for j=1:size(aa.v,2)
                    u = plot3(param.totalPathLength./max([eval1.merge(i,j,1).sum],1), param.totalPathLength./[eval1.split(i,j,1).sum], [eval1.general(i,j,1).maxNrObjects],...
                        marker{1}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
                    v = plot3(param.totalPathLength./max([eval2.merge(i,j,1).sum],1), param.totalPathLength./[eval2.split(i,j,1).sum], [eval2.general(i,j,1).maxNrObjects],...
                        marker{2}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
                    w = plot3(param.totalPathLength./max([eval3.merge(i,j,1).sum],1), param.totalPathLength./[eval3.split(i,j,1).sum], [eval3.general(i,j,1).maxNrObjects],...
                        marker{3}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
                end
            end
        end
    end
end

end

