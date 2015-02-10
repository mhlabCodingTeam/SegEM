function visualizeOverview_5cortex( param,paramTest )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here            
load(param.cmSource);
if ~exist([param.dataFolder param.figureSubfolder '/'], 'dir')
    mkdir([param.dataFolder param.figureSubfolder '/']);
end
[param,paramTest] = equalizeSkeletons(param,paramTest);
display('Overview Training vs. Test Comparison');
figure('position', [1 1 1600 785]);
hold on;
[a, b, c] = plotParam(param, autoKLEE_colormap(1,:));
[d, e, f] = plotParam(paramTest, autoKLEE_colormap(2,:));
xlabel('average distance between merger [nm]');
ylabel('average distance between splits [nm]');
zlabel('# objects');
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
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
                u = plot3(param.totalPathLength./max([eval1.merge.sum],1), param.totalPathLength./[eval1.split.sum], [eval1.general.maxNrObjects],...
                    marker{1}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
                v = plot3(param.totalPathLength./max([eval2.merge.sum]), param.totalPathLength./[eval2.split.sum], [eval2.general.maxNrObjects],...
                    marker{2}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
                w = plot3(param.totalPathLength./max([eval3.merge.sum],1), param.totalPathLength./[eval3.split.sum], [eval3.general.maxNrObjects],...
                    marker{3}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
        end
    end
end

function [param,paramTest] = equalizeSkeletons(param,paramTest)
    for i=1:length(param.skel)
       param.nrNodes(i) = size(param.skel{i}.nodes,1);
    end
    param.density = param.totalPathLength./sum(param.nrNodes);
    display(['Statistics dense training before downsampling:']);
    display([num2str(sum(param.nrNodes), '%.0i') ' nodes']);
    display([num2str(param.totalPathLength/1e6, '%.2f') ' path length [mm]']);
    display([num2str(param.density, '%.1f') ' path length per node [nm]']);
    display([num2str(param.totalPathLength/1e3/347, '%.2f') ' path length per volume [microns/microns^3]']);
    for i=1:length(paramTest.skel)
       paramTest.nrNodes(i) = size(paramTest.skel{i}.nodes,1);
    end
    paramTest.density = paramTest.totalPathLength./sum(paramTest.nrNodes);
    display(['Statistics dense test:']);
    display([num2str(sum(paramTest.nrNodes), '%.0i') ' nodes']);
    display([num2str(paramTest.totalPathLength/1e6, '%.2f') ' path length [mm]']);
    display([num2str(paramTest.density, '%.1f') ' path length per node [nm]']);
    display([num2str(paramTest.totalPathLength/1e3/95.5, '%.2f') ' path length per volume [microns/microns^3]']);
    fractionToDrop = 1 - param.density ./ paramTest.density;
    fractionToDrop = 1.2*fractionToDrop;
    for i=1:length(param.skel)
        r = rand(size(param.skel{i}.nodes,1),1);
        toDel = r < fractionToDrop;
        param.skel{i} = removeNodes(param.skel{i}, toDel);
    end
    param.totalPathLength = getPathLength(param.skel);
    for i=1:length(param.skel)
       param.nrNodes(i) = size(param.skel{i}.nodes,1);
    end
    param.density = param.totalPathLength./sum(param.nrNodes);
    display(['Statistics dense training after downsampling:']);
    display([num2str(sum(param.nrNodes), '%.0i') ' nodes']);
    display([num2str(param.totalPathLength/1e6, '%.2f') ' path length [mm]']);
    display([num2str(param.density, '%.1f') ' path length per node [nm]']);
    display([num2str(param.totalPathLength/1e3/347, '%.2f') ' path length per volume [microns/microns^3]']);
end

function skel = removeNodes(skel, toDel)
    ids = 1:size(skel.nodes,1);
    skel.nodes(toDel,:) = [];
    idsToDel = ids(toDel);
    idsToKeep = ids(~toDel);
    for i=1:length(idsToDel)
        edgesToDel = skel.edges == idsToDel(i);
        [row,col] = find(edgesToDel);
        col(col==2) = 0;
        col = col + 1;
        idsToJoin = skel.edges(row,col);
        idsToJoin = idsToJoin(:);
        idsToJoin(idsToJoin == idsToDel(i)) = [];
        idsToJoin = unique(idsToJoin);
        skel.edges(row,:) = [];
        for j=2:length(idsToJoin)
                skel.edges(end+1,:) = [idsToJoin(1) idsToJoin(j)];
        end
    end
    for i=1:length(idsToKeep)
        skel.edges(skel.edges == idsToKeep(i)) = i;
    end
end

end

