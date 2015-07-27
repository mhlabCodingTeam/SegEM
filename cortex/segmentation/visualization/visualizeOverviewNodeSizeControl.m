function visualizeOverviewNodeSizeControl( param, paramTest)

if ~exist([param.dataFolder param.figureSubfolder '/'], 'dir')
    mkdir([param.dataFolder param.figureSubfolder '/']);
end
display('Control Plot Node Size Threshold, see reviewer 2 comment 9');
figure('position', [1 1 1600 785]);
hold on;
[a, b, c] = plotParam(paramTest, [0 0 0], 1);
[d, e, f] = plotParam(paramTest, [0.5 0 0], 3);
[g, h, k] = plotParam(paramTest, [1 0 0], 5);
xlabel('average distance between merger [nm]');
ylabel('average distance between splits [nm]');
zlabel('# objects');
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
grid off;
legend([a b c d e f g h k], 'nT 1; nS 1', 'nT 2; nS 1', 'nT 3 nS 1', 'nT 1; nS 3', 'nT 2; nS 3', 'nT 3 nS 3',...
    'nT 1; nS 5', 'nT 2; nS 5', 'nT 3 nS 5');
saveas(gcf, [param.dataFolder param.figureSubfolder filesep 'overviewComparisonNew.fig']);

function [u, v, w] = plotParam(param, color, nodeSize)
    marker = {'+' 'o' 'x'};
    paramCell = getParamCombinations(param.algo);   
    for i=1:1%only first algo for cortex size(paramCell,2)
        for j=1:length(paramCell{i})
                display([num2str(j, '%.3i') ' of ' num2str(length(paramCell{i}), '%.3i')]);
                load([param.dataFolder param.outputSubfolder  param.affMaps(1).name filesep 'seg' num2str(0) '-' num2str(i) '-' num2str(j) '.mat'], 'v');
                eval1 = evaluateSeg(v, param.skel, 1, nodeSize);
                eval2 = evaluateSeg(v, param.skel, 2, nodeSize);
                eval3 = evaluateSeg(v, param.skel, 3, nodeSize);
                u = plot3(param.totalPathLength./max(eval1.merge.sum,1), param.totalPathLength./max(eval1.split.sum,1), eval1.general.maxNrObjects,...
                    marker{1}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
                v = plot3(param.totalPathLength./max(eval2.merge.sum,1), param.totalPathLength./max(eval2.split.sum,1), eval2.general.maxNrObjects,...
                    marker{2}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
                w = plot3(param.totalPathLength./max(eval3.merge.sum,1), param.totalPathLength./max(eval3.split.sum,1), eval3.general.maxNrObjects,...
                    marker{3}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
        end
    end
end

end

