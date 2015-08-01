function visualizeOverviewWithThreeLinesAndZeroHits( param,paramTest,nodeSize )
% Sorry for bad form, was done in a hurry! :) like most of this stuff xD

if nargin == 2
    nodeSize = 1;
end

if ~exist([param.dataFolder param.figureSubfolder '/'], 'dir')
    mkdir([param.dataFolder param.figureSubfolder '/']);
end
display('Overview Test Retina vs. Test Cortex extended comparison');
figure('position', [1 1 1600 785]);
hold on;
pp = load('D:\data\SegEM\segOptRetina\seg29-Jul-2015\parameter.mat');
[a, b, c, keptSamplesR, sampleCoordR] = plotParamLegacy(pp.param, [145/255 44/255 238/255], nodeSize);
[d, e, f, keptSamples, sampleCoord] = plotParam(paramTest, [0 205/255 205/255], nodeSize);
% RETINA
normalIdx = sub2ind([length(pp.param.r) length(pp.param.pR{2}{1}) length(pp.param.pR{2}{2})], 2, find(abs(pp.param.pR{2}{1} - 0.3) < 0.001), find(pp.param.pR{2}{2} == 150));
l = plot3(squeeze(sampleCoordR(normalIdx,1:2,1)),squeeze(sampleCoordR(normalIdx,1:2,2)),squeeze(sampleCoordR(normalIdx,1:2,3)), '--', 'Color', [93/255 71/255 139/255], 'LineWidth', 2);
wholeCellIdx = sub2ind([length(pp.param.r) length(pp.param.pR{2}{1}) length(pp.param.pR{2}{1})], 2, find(abs(pp.param.pR{2}{1} - 0.31) < 0.001), find(pp.param.pR{2}{2} == 20));
m = plot3(squeeze(sampleCoordR(wholeCellIdx,1:2,1)),squeeze(sampleCoordR(wholeCellIdx,1:2,2)),squeeze(sampleCoordR(wholeCellIdx,1:2,3)), ':', 'Color', [93/255 71/255 139/255], 'LineWidth', 2);
% Plot optimal IEDs
keptSampleCoord1 = squeeze(sampleCoordR(keptSamplesR(:,1),1,:));
keptSampleCoord2 = squeeze(sampleCoordR(keptSamplesR(:,2),2,:));
keptSampleCoord3 = squeeze(sampleCoordR(keptSamplesR(:,3),3,:));
% Group 3 NN
keptSampleCoord1 = extractCoM(keptSampleCoord1);
keptSampleCoord2 = extractCoM(keptSampleCoord2);
keptSampleCoord3 = extractCoM(keptSampleCoord3);
tempIED1 = 1./(1./keptSampleCoord1(:,1)+1./keptSampleCoord1(:,2));
tempIED2 = 1./(1./keptSampleCoord2(:,1)+1./keptSampleCoord2(:,2));
tempIED3 = 1./(1./keptSampleCoord3(:,1)+1./keptSampleCoord3(:,2));
[maxVal1, maxID1] = max(tempIED1);
[maxVal2, maxID2] = max(tempIED2);
[maxVal3, maxID3] = max(tempIED3);
X = [keptSampleCoord1(maxID1,1) keptSampleCoord2(maxID2,1) keptSampleCoord3(maxID3,1)];
Y = [keptSampleCoord1(maxID1,2) keptSampleCoord2(maxID2,2) keptSampleCoord3(maxID3,2)];
Z = [keptSampleCoord1(maxID1,3) keptSampleCoord2(maxID2,3) keptSampleCoord3(maxID3,3)];
n = plot3(X,Y,Z, 'sg', 'MarkerSize', 8, 'LineWidth', 2);
text(X(1),Y(1),['\leftarrow optimal IED: ' num2str(maxVal1/1000, '%3.2f') 'microns']);
text(X(2),Y(2),['\leftarrow optimal IED: ' num2str(maxVal2/1000, '%3.2f') 'microns']);
text(X(3),Y(3),['\leftarrow optimal IED: ' num2str(maxVal3/1000, '%3.2f') 'microns']);
% CORTEX 
% New section, plot 3-Lines
% First get parameter used for each segmentation
temp = getParamCombinations(param.algo);
temp = cat(1,temp{1}{:});
temp = temp(:,2);
temp = cell2mat(cat(1,temp{:}));
% Plot first line, normal segmentation a.k.a. red dot
normalIdx = all(bsxfun(@eq, temp, [0.39 50]),2);
g = plot3(squeeze(sampleCoord(normalIdx,1:2,1)),squeeze(sampleCoord(normalIdx,1:2,2)),squeeze(sampleCoord(normalIdx,1:2,3)), '--', 'Color', [0 139/255 139/255], 'LineWidth', 2);
% Plot first line, whole cell segmentation a.k.a. yellow dot
wholeCellIdx = all(bsxfun(@eq, temp, [0.25 10]),2);
h = plot3(squeeze(sampleCoord(wholeCellIdx,1:2,1)),squeeze(sampleCoord(wholeCellIdx,1:2,2)),squeeze(sampleCoord(wholeCellIdx,1:2,3)), ':', 'Color', [0 139/255 139/255], 'LineWidth', 2);
% Plot optimal IEDs
keptSampleCoord1 = squeeze(sampleCoord(keptSamples(:,1),1,:));
keptSampleCoord2 = squeeze(sampleCoord(keptSamples(:,2),2,:));
keptSampleCoord3 = squeeze(sampleCoord(keptSamples(:,3),3,:));
% Group 3 NN
keptSampleCoord1 = extractCoM(keptSampleCoord1);
keptSampleCoord2 = extractCoM(keptSampleCoord2);
keptSampleCoord3 = extractCoM(keptSampleCoord3);
tempIED1 = 1./(1./keptSampleCoord1(:,1)+1./keptSampleCoord1(:,2));
tempIED2 = 1./(1./keptSampleCoord2(:,1)+1./keptSampleCoord2(:,2));
tempIED3 = 1./(1./keptSampleCoord3(:,1)+1./keptSampleCoord3(:,2));
[maxVal1, maxID1] = max(tempIED1);
[maxVal2, maxID2] = max(tempIED2);
[maxVal3, maxID3] = max(tempIED3);
X = [keptSampleCoord1(maxID1,1) keptSampleCoord2(maxID2,1) keptSampleCoord3(maxID3,1)];
Y = [keptSampleCoord1(maxID1,2) keptSampleCoord2(maxID2,2) keptSampleCoord3(maxID3,2)];
Z = [keptSampleCoord1(maxID1,3) keptSampleCoord2(maxID2,3) keptSampleCoord3(maxID3,3)];
k = plot3(X,Y,Z, '*g', 'LineWidth', 2);
text(X(1),Y(1),['\leftarrow optimal IED: ' num2str(maxVal1/1000, '%3.2f') 'microns']);
text(X(2),Y(2),['\leftarrow optimal IED: ' num2str(maxVal2/1000, '%3.2f') 'microns']);
text(X(3),Y(3),['\leftarrow optimal IED: ' num2str(maxVal3/1000, '%3.2f') 'microns']);
% Formatting
xlabel('average distance between merger [microns]');
ylabel('average distance between splits [microns]');
zlabel('fraction zero hits');
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
set(gca, 'XTick', [1e4 1e5 1e6]);
set(gca, 'XTickLabel', [10 100 1000]);
set(gca, 'YTick', [1e3 1e4 1e5]);
set(gca, 'YTickLabel', [1 10 100]);
grid off;
legend([a b c d e f l m n g h k],'retina test node threshold 1', 'retina test node threshold 2', 'retina test node threshold 3', ...
    'cortex test node threshold 1', 'cortex test node threshold 2', 'cortex test node threshold 3', ...
    'retina segmentation normal', 'retina segmentation whole cell', 'retina best inter-error of 3 NN',...
    'cortex segmentation normal', 'cortex segmentation whole cell', 'cortex best inter-error of 3 NN');
saveas(gcf, [param.dataFolder param.figureSubfolder filesep 'overviewComparisonNew3LAZH.fig']);
end

function [u, v, w, kept, plotted] = plotParam(param, color, nodeSize)
marker = {'+' 'o' 'x'};
paramCell = getParamCombinations(param.algo);
for i=1:1 %only first algo for cortex right now
    for j=1:length(paramCell{i})
        display([num2str(j, '%.3i') ' of ' num2str(length(paramCell{i}), '%.3i')]);
        load([param.dataFolder param.outputSubfolder  param.affMaps(1).name filesep 'seg' num2str(0) '-' num2str(i) '-' num2str(j) '.mat'], 'v');
        eval1 = evaluateSeg(v, param.skel, 1, nodeSize);
        eval2 = evaluateSeg(v, param.skel, 2, nodeSize);
        eval3 = evaluateSeg(v, param.skel, 3, nodeSize);
        kept(j,1) = eval1.split.sum > 1 && eval1.merge.sum > 1;
        kept(j,2) = eval2.split.sum > 1 && eval2.merge.sum > 1;
        kept(j,3) = eval3.split.sum > 1 && eval3.merge.sum > 1;
        plotted(j,1,1) = param.totalPathLength./max(eval1.merge.sum,1);
        plotted(j,1,2) = param.totalPathLength./max(eval1.split.sum,1);
        plotted(j,1,3) = eval1.general.zeroHits./eval1.general.nodesTotal;
        plotted(j,2,1) = param.totalPathLength./max(eval2.merge.sum,1);
        plotted(j,2,2) = param.totalPathLength./max(eval2.split.sum,1);
        plotted(j,2,3) = eval2.general.zeroHits./eval2.general.nodesTotal;
        plotted(j,3,1) = param.totalPathLength./max(eval3.merge.sum,1);
        plotted(j,3,2) = param.totalPathLength./max(eval3.split.sum,1);
        plotted(j,3,3) = eval3.general.zeroHits./eval3.general.nodesTotal;
        if kept(j,1)
            u = plot3(plotted(j,1,1), plotted(j,1,2), plotted(j,1,3),...
                marker{1}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
        else
            %plot3(plotted(j,1,1), plotted(j,1,2), plotted(j,1,3),...
            %    marker{1}, 'MarkerEdgeColor', [.6 .6 .6], 'MarkerSize', 5);
        end
        if kept(j,2)
            v = plot3(plotted(j,2,1), plotted(j,2,2), plotted(j,2,3),...
                marker{2}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
        else
            %plot3(plotted(j,2,1), plotted(j,2,2), plotted(j,2,3),...
            %    marker{2}, 'MarkerEdgeColor', [.6 .6 .6], 'MarkerSize', 5);
        end
        if kept(j,3)
            w = plot3(plotted(j,3,1), plotted(j,3,2), plotted(j,3,3),...
                marker{3}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
        else
            %plot3(plotted(j,3,1), plotted(j,3,2), plotted(j,3,3),...
            %    marker{3}, 'MarkerEdgeColor', [.6 .6 .6], 'MarkerSize', 5);
        end
    end
end
end

function [u, v, w, kept, plotted] = plotParamLegacy(param, color, nodeSize)
marker = {'+' 'o' 'x'};
map=1;
for algo=2%threshold only used for retina currently
    for r=1:length(param.r)
        tic;
        a = load([param.dataFolder param.outputSubfolder param.affMaps(map).name filesep 'seg' num2str(r) '-' num2str(algo) '.mat'], 'v');
        toc;
        for i=1:size(a.v,1)
            for j=1:size(a.v,2)
                display(num2str([r i j]));
                eval1 = evaluateSeg(a.v{i,j}, param.skel, 1, nodeSize);
                eval2 = evaluateSeg(a.v{i,j}, param.skel, 2, nodeSize);
                eval3 = evaluateSeg(a.v{i,j}, param.skel, 3, nodeSize);
                idx = sub2ind([length(param.r) size(a.v)], r, i, j);
                kept(idx,1) = eval1.split.sum > 1 && eval1.merge.sum > 1;
                kept(idx,2) = eval2.split.sum > 1 && eval2.merge.sum > 1;
                kept(idx,3) = eval3.split.sum > 1 && eval3.merge.sum > 1;
                plotted(idx,1,1) = param.totalPathLength./max(eval1.merge.sum,1);
                plotted(idx,1,2) = param.totalPathLength./max(eval1.split.sum,1);
                plotted(idx,1,3) = eval1.general.zeroHits./eval1.general.nodesTotal;
                plotted(idx,2,1) = param.totalPathLength./max(eval2.merge.sum,1);
                plotted(idx,2,2) = param.totalPathLength./max(eval2.split.sum,1);
                plotted(idx,2,3) = eval2.general.zeroHits./eval2.general.nodesTotal;
                plotted(idx,3,1) = param.totalPathLength./max(eval3.merge.sum,1);
                plotted(idx,3,2) = param.totalPathLength./max(eval3.split.sum,1);
                plotted(idx,3,3) = eval3.general.zeroHits./eval3.general.nodesTotal;
                if kept(idx,1)
                    u = plot3(plotted(idx,1,1), plotted(idx,1,2), plotted(idx,1,3),...
                        marker{1}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
                else
                    %plot3(plotted(j,1,1), plotted(j,1,2), plotted(j,1,3),...
                    %    marker{1}, 'MarkerEdgeColor', [.6 .6 .6], 'MarkerSize', 5);
                end
                if kept(idx,2)
                    v = plot3(plotted(idx,2,1), plotted(idx,2,2), plotted(idx,2,3),...
                        marker{2}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
                else
                    %plot3(plotted(j,2,1), plotted(j,2,2), plotted(j,2,3),...
                    %    marker{2}, 'MarkerEdgeColor', [.6 .6 .6], 'MarkerSize', 5);
                end
                if kept(idx,3)
                    w = plot3(plotted(idx,3,1), plotted(idx,3,2), plotted(idx,3,3),...
                        marker{3}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
                else
                    %plot3(plotted(j,3,1), plotted(j,3,2), plotted(j,3,3),...
                    %    marker{3}, 'MarkerEdgeColor', [.6 .6 .6], 'MarkerSize', 5);
                end
            end
        end
    end
end
end

function comThreeNearestNeighbours = extractCoM(pointList)
for i=1:size(pointList,1)
    distances = sqrt(sum((pointList - repmat(pointList(i,:),size(pointList,1),1)).^2,2));
    [~,idx] = sort(distances);
    comThreeNearestNeighbours(i,:) = mean(pointList(idx(1:3),:),1);
end
end
