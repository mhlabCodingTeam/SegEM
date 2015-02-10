function visualizeOverviewTestComparisonRetinaVsCortex( paramRetinaTest,paramCortexTest )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here            
load(paramRetinaTest.cmSource);
display('Overview Training vs. Test Comparison');
figure('position', [1 1 1600 785]);
hold on;
% DEBUG
% load([paramCortexTest.dataFolder paramCortexTest.outputSubfolder  paramCortexTest.affMaps(1).name filesep 'seg' num2str(0) '-' num2str(1) '-' num2str(1) '.mat'], 'segmentation');
% evalBefore = evaluateSegCortex(segmentation, paramCortexTest.skel, 2);
% evalAfter = evaluateSegCortex(segmentation, paramCortexTest2.skel, 2);
% DEBUG END
[a,b,c] = plotParamRetina(paramRetinaTest, autoKLEE_colormap(1,:));
[d,e,f] = plotParamCortex(paramCortexTest, autoKLEE_colormap(2,:));
xlabel('average distance between merger [nm]');
ylabel('average distance between splits [nm]');
zlabel('# objects');
grid on;
legend([a b c d e f], 'test retina node threshold 1', 'test retina node threshold 2', 'test retina node threshold 3' ...
    , 'test cortex node threshold 1', 'test cortex node threshold 2', 'test cortex node threshold 3');
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
saveas(gcf, [paramRetinaTest.dataFolder paramRetinaTest.figureSubfolder '/overviewComparison.fig']);

function [u,v,w] = plotParamRetina(param, color)
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

function [u, v, w] = plotParamCortex(param, color)
    marker = {'+' 'o' 'x'};
    paramCell = getParamCombinations(param.algo);   
    for i=1:1%only first algo for cortex size(paramCell,2)
        for j=1:length(paramCell{i})
                display([num2str(j, '%.3i') ' of ' num2str(length(paramCell{i}), '%.3i')]);
                load([param.dataFolder param.outputSubfolder  param.affMaps(1).name filesep 'seg' num2str(0) '-' num2str(i) '-' num2str(j) '.mat'], 'segmentation');
                eval1 = evaluateSegCortex(segmentation, param.skel, 1);
                eval2 = evaluateSegCortex(segmentation, param.skel, 2);
                eval3 = evaluateSegCortex(segmentation, param.skel, 3);
                u = plot3(param.totalPathLength./max([eval1.merge.sum],1), param.totalPathLength./[eval1.split.sum], [eval1.general.maxNrObjects],...
                    marker{1}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
                v = plot3(param.totalPathLength./max([eval2.merge.sum],1), param.totalPathLength./[eval2.split.sum], [eval2.general.maxNrObjects],...
                    marker{2}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
                w = plot3(param.totalPathLength./max([eval3.merge.sum],1), param.totalPathLength./[eval3.split.sum], [eval3.general.maxNrObjects],...
                    marker{3}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
        end
    end
end

function [paramRetina,paramCortex] = equalizeSkeletons(paramRetina,paramCortex)
    for i=1:length(paramRetina.skel)
       paramRetina.nrNodes(i) = size(paramRetina.skel{i}.nodes,1);
    end
    paramRetina.density = paramRetina.totalPathLength./sum(paramRetina.nrNodes);
    display(['Statistics dense test retina:']);
    display([num2str(sum(paramRetina.nrNodes), '%.0i') ' nodes']);
    display([num2str(paramRetina.totalPathLength/1e6, '%.2f') ' path length [mm]']);
    display([num2str(paramRetina.density, '%.1f') ' path length per node [nm]']);
    display([num2str(paramRetina.totalPathLength/1e3/202, '%.2f') ' path length per volume [microns/microns^3]']);
    for i=1:length(paramCortex.skel)
       paramCortex.nrNodes(i) = size(paramCortex.skel{i}.nodes,1);
    end
    paramCortex.density = paramCortex.totalPathLength./sum(paramCortex.nrNodes);
    display(['Statistics dense test cortex before downsampling:']);
    display([num2str(sum(paramCortex.nrNodes), '%.0i') ' nodes']);
    display([num2str(paramCortex.totalPathLength/1e6, '%.2f') ' path length [mm]']);
    display([num2str(paramCortex.density, '%.1f') ' path length per node [nm]']);
    display([num2str(paramCortex.totalPathLength/1e3/95.5, '%.2f') ' path length per volume [microns/microns^3]']);
    fractionToDrop = 1 - paramCortex.density ./ paramRetina.density;
    fractionToDrop = 1.3*fractionToDrop;
    for i=1:length(paramCortex.skel)
        r = rand(size(paramCortex.skel{i}.nodes,1),1);
        toDel = r < fractionToDrop;
        paramCortex.skel{i} = removeNodes(paramCortex.skel{i}, toDel);
    end
    paramCortex.totalPathLength = getPathLength(paramCortex.skel);
    for i=1:length(paramCortex.skel)
       paramCortex.nrNodes(i) = size(paramCortex.skel{i}.nodes,1);
    end
    paramCortex.density = paramCortex.totalPathLength./sum(paramCortex.nrNodes);
    display(['Statistics dense test cortex after downsampling:']);
    display([num2str(sum(paramCortex.nrNodes), '%.0i') ' nodes']);
    display([num2str(paramCortex.totalPathLength/1e6, '%.2f') ' path length [mm]']);
    display([num2str(paramCortex.density, '%.1f') ' path length per node [nm]']);
    display([num2str(paramCortex.totalPathLength/1e3/95.5, '%.2f') ' path length per volume [microns/microns^3]']);
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

