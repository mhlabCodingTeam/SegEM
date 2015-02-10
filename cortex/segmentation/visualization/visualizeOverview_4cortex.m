function visualizeOverview_4cortex( param,paramTest )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here            
load(param.cmSource);
if ~exist([param.dataFolder param.figureSubfolder '/'], 'dir')
    mkdir([param.dataFolder param.figureSubfolder '/']);
end

display('Overview Training vs. Test Comparison');
figure('position', [1 1 1600 785]);
hold on;
[a, b, c] = plotParam(param, autoKLEE_colormap(1,:));
[d, e, f] = plotParam(paramTest, autoKLEE_colormap(2,:));
xlabel('average distance between merger [nm]');
ylabel('average distance between splits [nm]');
zlabel('# objects');
grid on;
legend([a b c d e f], 'training node threshold 1', 'training node threshold 2', 'training node threshold 3' ...
    , 'test node threshold 1', 'test node threshold 2', 'test node threshold 3');
saveas(gcf, [param.dataFolder param.figureSubfolder '/overviewComparison.fig']);

function [u, v, w] = plotParam(param, color)
    marker = {'+' 'o' 'x'};
    paramCell = getParamCombinations(param.algo);   
    for i=1:1%only first algo for cortex size(paramCell,2)
        for j=1:length(paramCell{i})
                display([num2str(j, '%.3i') ' of ' num2str(length(paramCell{i}), '%.3i')]);
                load([param.dataFolder param.outputSubfolder  param.affMaps(1).name filesep 'seg' num2str(0) '-' num2str(i) '-' num2str(j) '.mat'], 'segmentation');
                eval1 = evaluateSeg(segmentation, param.skel, 1);
                eval2 = evaluateSeg(segmentation, param.skel, 2);
                eval3 = evaluateSeg(segmentation, param.skel, 3);
                u = plot3(param.totalPathLength./[eval1.merge.sum], param.totalPathLength./[eval1.split.sum], [eval1.general.maxNrObjects],...
                    marker{1}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
                v = plot3(param.totalPathLength./[eval2.merge.sum], param.totalPathLength./[eval2.split.sum], [eval2.general.maxNrObjects],...
                    marker{2}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
                w = plot3(param.totalPathLength./[eval3.merge.sum], param.totalPathLength./[eval3.split.sum], [eval3.general.maxNrObjects],...
                    marker{3}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
        end
    end
end

function string = printParams(cell)
    string = '';
    for i=1:length(cell)
        if(i~=1)
            string = [string '-'];
        end     
        string = [string num2str(cell{i})]; 
    end
end

end

