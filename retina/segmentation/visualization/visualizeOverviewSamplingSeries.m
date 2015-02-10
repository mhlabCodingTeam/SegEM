function visualizeOverviewSamplingSeries( paramRetinaTest,paramCortexTest )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
for sk=1:length(paramRetinaTest.skel)
   paramRetinaTest.nrNodes(sk) = size(paramRetinaTest.skel{sk}.nodes,1);
end
paramRetinaTest.density = paramRetinaTest.totalPathLength./sum(paramRetinaTest.nrNodes);
for sk=1:length(paramCortexTest.skel)
   paramCortexTest.nrNodes(sk) = size(paramCortexTest.skel{sk}.nodes,1);
end
paramCortexTest.density = paramCortexTest.totalPathLength./sum(paramCortexTest.nrNodes);
for thres=1:13
    [~,paramCortexTest2(thres)] = equalizeSkeletons(paramRetinaTest,paramCortexTest,thres*0.1);
end
display('Overview Training vs. Test Comparison');
figure('position', [1 1 1600 785]);
hold on;
% Normalize density
maxVal = max([paramRetinaTest.density paramCortexTest.density, paramCortexTest2(:).density]);
minVal = min([paramRetinaTest.density paramCortexTest.density, paramCortexTest2(:).density]);
paramRetinaTest.density = (paramRetinaTest.density-minVal)./(maxVal-minVal);
paramCortexTest.density = (paramCortexTest.density-minVal)./(maxVal-minVal);
for thres=1:13
    paramCortexTest2(thres).density = (paramCortexTest2(thres).density-minVal)./(maxVal-minVal);
end
% Normalization end
% DEBUG
% load([paramCortexTest.dataFolder paramCortexTest.outputSubfolder  paramCortexTest.affMaps(1).name filesep 'seg' num2str(0) '-' num2str(1) '-' num2str(1) '.mat'], 'segmentation');
% evalBefore = evaluateSegCortex(segmentation, paramCortexTest.skel, 2);
% evalAfter = evaluateSegCortex(segmentation, paramCortexTest2.skel, 2);
% DEBUG END
a = plotParamRetina(paramRetinaTest);
b = plotParamCortex(paramCortexTest);
for thres=1:13
    plotParamCortex(paramCortexTest2(thres));
end
xlabel('average distance between merger [nm]');
ylabel('average distance between splits [nm]');
zlabel('# objects');
grid on;
legend([a b], 'retina node threshold 2');
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
saveas(gcf, '/p/overviewSamplingSeriesFinal.fig');

function u = plotParamRetina(param)
    for r=1:2
        for algo=2
            load([param.dataFolder param.outputSubfolder  param.affMaps(1).name filesep 'seg' num2str(r) '-' num2str(algo) '.mat'], 'v');
%             eval1 = evaluateSeg(v, param.skel, 1);
            eval2 = evaluateSeg(v, param.skel, 2);
%             eval3 = evaluateSeg(v, param.skel, 3);
            for i=1:size(v,1)
                for j=1:size(v,2)
%                     u = scatter3(param.totalPathLength./max([eval1.merge(i,j,1).sum],1), param.totalPathLength./[eval1.split(i,j,1).sum], [eval1.general(i,j,1).maxNrObjects],...
%                         10, [param.density 1-param.density 0], '+');
                    u = scatter3(param.totalPathLength./max([eval2.merge(i,j,1).sum],1), param.totalPathLength./[eval2.split(i,j,1).sum], [eval2.general(i,j,1).maxNrObjects],...
                        10, [param.density 1-param.density 0], '+');
%                     u = scatter3(param.totalPathLength./max([eval3.merge(i,j,1).sum],1), param.totalPathLength./[eval3.split(i,j,1).sum], [eval3.general(i,j,1).maxNrObjects],...
%                         10, [param.density 1-param.density 0], '+');
                end
            end
        end
    end
end

function u = plotParamCortex(param)
    paramCell = getParamCombinations(param.algo);
    for i=1:1%only first algo for cortex size(paramCell,2)
        for j=1:length(paramCell{i})
                display([num2str(j, '%.3i') ' of ' num2str(length(paramCell{i}), '%.3i')]);
                load([param.dataFolder param.outputSubfolder  param.affMaps(1).name filesep 'seg' num2str(0) '-' num2str(i) '-' num2str(j) '.mat'], 'segmentation');
%                 eval1 = evaluateSegCortex(segmentation, param.skel, 1);
                eval2 = evaluateSegCortex(segmentation, param.skel, 2);
%                 eval3 = evaluateSegCortex(segmentation, param.skel, 3);
%                 u = scatter3(param.totalPathLength./max([eval1.merge.sum],1), param.totalPathLength./[eval1.split.sum], [eval1.general.maxNrObjects],...
%                     10, [param.density 1-param.density 0], 'x');
                u = scatter3(param.totalPathLength./max([eval2.merge.sum],1), param.totalPathLength./[eval2.split.sum], [eval2.general.maxNrObjects],...
                    10, [param.density 1-param.density 0], 'x');
%                 u = scatter3(param.totalPathLength./max([eval3.merge.sum],1), param.totalPathLength./[eval3.split.sum], [eval3.general.maxNrObjects],...
%                     10, [param.density 1-param.density 0], 'x');
        end
    end
end

function [paramRetina,paramCortex] = equalizeSkeletons(paramRetina,paramCortex,howMuch)
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
    fractionToDrop = howMuch*fractionToDrop;
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

