function visualizeOverviewWithThreeLinesAndZeroHits( param,paramTest,nodeSize )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here            

if nargin == 2
    nodeSize = 1;
end

% load/extract retina test set
uiopen('Z:\Personal\berningm\paper\paper1_automated_segmentation\old\figuresPaper\v12\old\splitMergerRetinaFinal_net5.fig',1);
g = gca; a = findobj(g.Children, 'Marker', '+');
bb = []; for i=1:length(a); bb(i,:) = [get(a(i), 'XData') get(a(i), 'YData')]; end
c = []; for i=1:length(a); c(i,:) = get(a(i), 'MarkerEdgeColor'); end
rightColor = sqrt(sum((c - repmat([0.7962 0.3082 0.1910],size(c,1),1)).^2,2)) < 0.1;
bb = bb(rightColor,:);
%uiopen('Z:\Personal\berningm\paper\paper1_automated_segmentation\old\figuresPaper\v12\old\splitMergerRetinaFinal_net5.fig',1);
g = gca; a = findobj(g.Children, 'Marker', 'o');
dd = []; for i=1:length(a); dd(i,:) = [get(a(i), 'XData') get(a(i), 'YData')]; end
c = []; for i=1:length(a); c(i,:) = get(a(i), 'MarkerEdgeColor'); end
rightColor = sqrt(sum((c - repmat([0.7962 0.3082 0.1910],size(c,1),1)).^2,2)) < 0.1;
dd = dd(rightColor,:);
%uiopen('Z:\Personal\berningm\paper\paper1_automated_segmentation\old\figuresPaper\v12\old\splitMergerRetinaFinal_net5.fig',1);
g = gca; a = findobj(g.Children, 'Marker', 'x');
ee = []; for i=1:length(a); ee(i,:) = [get(a(i), 'XData') get(a(i), 'YData')]; end
c = []; for i=1:length(a); c(i,:) = get(a(i), 'MarkerEdgeColor'); end
rightColor = sqrt(sum((c - repmat([0.7962 0.3082 0.1910],size(c,1),1)).^2,2)) < 0.1;
ee = ee(rightColor,:);
close gcf;


if ~exist([param.dataFolder param.figureSubfolder '/'], 'dir')
    mkdir([param.dataFolder param.figureSubfolder '/']);
end
display('Overview Training vs. Test Comparison');
figure('position', [1 1 1600 785]);
hold on;
plot3(bb(:,1),bb(:,2),zeros(size(bb,1),1), '+m');
plot3(dd(:,1),dd(:,2),zeros(size(dd,1),1), 'om');
plot3(ee(:,1),ee(:,2),zeros(size(ee,1),1), 'xm');
%[a, b, c] = plotParam(param, [0 0 0]);
[d, e, f, keptSamples, sampleCoord] = plotParam(paramTest, [0.05 0.5 0.25], nodeSize);
% New section, plot 3-Lines
% First get parameter used for each segmentation
temp = getParamCombinations(param.algo);   
temp = cat(1,temp{1}{:});
temp = temp(:,2);
temp = cell2mat(cat(1,temp{:}));
% Plot first line, normal segmentation a.k.a. red dot
normalIdx = all(bsxfun(@eq, temp, [0.39 50]),2);
g = plot3(squeeze(sampleCoord(normalIdx,1:2,1)),squeeze(sampleCoord(normalIdx,1:2,2)),squeeze(sampleCoord(normalIdx,1:2,3)), '-r', 'LineWidth', 2);

% Plot first line, whole cell segmentation a.k.a. yellow dot
wholeCellIdx = all(bsxfun(@eq, temp, [0.25 10]),2);
h = plot3(squeeze(sampleCoord(wholeCellIdx,1:2,1)),squeeze(sampleCoord(wholeCellIdx,1:2,2)),squeeze(sampleCoord(wholeCellIdx,1:2,3)), '-y', 'LineWidth', 2);
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
k = plot3(X,Y,Z, 'og', 'LineWidth', 2);
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
legend([d e f g h k], 'test node threshold 1', 'test node threshold 2', 'test node threshold 3', 'segmentation normal', 'segmentation whole cell', 'best inter-error');
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
            kept(j,1) = eval1.split.sum > 2 && eval1.merge.sum > 1;
            kept(j,2) = eval2.split.sum > 2 && eval2.merge.sum > 1;
            kept(j,3) = eval3.split.sum > 2 && eval3.merge.sum > 1;
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

function comThreeNearestNeighbours = extractCoM(pointList)
    for i=1:size(pointList,1)
        distances = sqrt(sum((pointList - repmat(pointList(i,:),size(pointList,1),1)).^2,2));
        [~,idx] = sort(distances);
        comThreeNearestNeighbours(i,:) = mean(pointList(idx(1:3),:),1);
    end
end
