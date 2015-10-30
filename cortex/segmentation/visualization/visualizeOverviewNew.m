function visualizeOverviewNew( param,paramTest,nodeSize )
% Pass param and paramTest (and optionally node size to plot 

if nargin == 2
    nodeSize = 1;
end

if ~exist([param.dataFolder param.figureSubfolder '/'], 'dir')
    mkdir([param.dataFolder param.figureSubfolder '/']);
end
display('Overview: Split-merger segmentation parameter grid search');
figure('position', [1 1 1600 785]);
hold on;
[d, e, keptSamples, sampleCoord, params] = plotParam(paramTest, [0 205/255 205/255], nodeSize);
% CORTEX 
% New section, plot 3-Lines
% First get parameter used for each segmentation
temp = getParamCombinations(param.algo);
temp = cat(1,temp{1}{:});
temp = temp(:,2);
temp = cell2mat(cat(1,temp{:}));
% Plot optimal IEDs
keptSampleCoord1T = squeeze(sampleCoord(keptSamples(:,1),1,:));
keptSampleCoord2T = squeeze(sampleCoord(keptSamples(:,2),2,:));
% Group 3 NN
[keptSampleCoord1, idx1, ied1] = extractCoM(keptSampleCoord1T);
[keptSampleCoord2, idx2, ied2] = extractCoM(keptSampleCoord2T);
tempIED1 = 1./(1./keptSampleCoord1(:,1)+1./keptSampleCoord1(:,2));
tempIED2 = 1./(1./keptSampleCoord2(:,1)+1./keptSampleCoord2(:,2));
[maxVal1, maxID1] = max(tempIED1);
[maxVal2, maxID2] = max(tempIED2);
X = [keptSampleCoord1(maxID1,1) keptSampleCoord2(maxID2,1)];
Y = [keptSampleCoord1(maxID1,2) keptSampleCoord2(maxID2,2)];
Z = [keptSampleCoord1(maxID1,3) keptSampleCoord2(maxID2,3)];
k = plot3(X,Y,Z, '*g', 'LineWidth', 2);
text(X(1),Y(1),['\leftarrow optimal IED: ' num2str(maxVal1/1000, '%3.2f') 'microns']);
text(X(2),Y(2),['\leftarrow optimal IED: ' num2str(maxVal2/1000, '%3.2f') 'microns']);
text(X(3),Y(3),['\leftarrow optimal IED: ' num2str(maxVal3/1000, '%3.2f') 'microns']);
% Output for parameters etc. of optimal IED
display('Node threshold 1, middle segmentation of 3 NN according to IED:');
display(['IED: ' num2str(ied1(maxID1)) ', Merger: ' num2str(keptSampleCoord1T(idx1(maxID1),1)) ', Split: ' num2str(keptSampleCoord1T(idx1(maxID1),2))]);
display(['Parameter = ' num2str(0) ', ' num2str(temp(idx1(maxID1),1)) ', ' num2str(temp(idx1(maxID1),2))]);
display('Node threshold 2, middle segmentation of 3 NN according to IED:');
display(['IED: ' num2str(ied2(maxID2)) ', Merger: ' num2str(keptSampleCoord2T(idx2(maxID2),1)) ', Split: ' num2str(keptSampleCoord2T(idx2(maxID2),2))]);
display(['Parameter = ' num2str(0) ', ' num2str(temp(idx2(maxID2),1)) ', ' num2str(temp(idx2(maxID2),2))]);
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
legend([d e k], 'cortex test node threshold 1', 'cortex test node threshold 2', 'cortex best inter-error of 3 NN');
saveas(gcf, [param.dataFolder param.figureSubfolder filesep 'overviewComparisonNew3LAZH.fig']);
end

function [u, v, kept, plotted, params] = plotParam(param, color, nodeSize)
marker = {'+' 'o' 'x'};
paramCell = getParamCombinations(param.algo);
idx = 1;
for r=1:length(param.r)
    for i=1:size(paramCell,2)
        for j=1:length(paramCell{i})
            load([param.dataFolder param.outputSubfolder  param.affMaps(1).name filesep 'seg' num2str(param.r(r)) '-' num2str(i) '-' num2str(j) '.mat'], 'v');
            eval1 = evaluateSeg(v, param.skel, 1, nodeSize);
            eval2 = evaluateSeg(v, param.skel, 2, nodeSize);
            kept(idx,1) = eval1.split.sum > 1 && eval1.merge.sum > 1;
            kept(idx,2) = eval2.split.sum > 1 && eval2.merge.sum > 1;
            plotted(idx,1,1) = param.totalPathLength./max(eval1.merge.sum,1);
            plotted(idx,1,2) = param.totalPathLength./max(eval1.split.sum,1);
            plotted(idx,1,3) = eval1.general.zeroHits./eval1.general.nodesTotal;
            plotted(idx,2,1) = param.totalPathLength./max(eval2.merge.sum,1);
            plotted(idx,2,2) = param.totalPathLength./max(eval2.split.sum,1);
            plotted(idx,2,3) = eval2.general.zeroHits./eval2.general.nodesTotal;
            params{idx} = [param.r(r) i paramCell{i}{j}{2}(1) paramCell{i}{j}{2}(2)];
            if kept(idx,1)
                u = plot3(plotted(idx,1,1), plotted(idx,1,2), plotted(idx,1,3),...
                    marker{1}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
            end
            if kept(idx,2)
                v = plot3(plotted(idx,2,1), plotted(idx,2,2), plotted(idx,2,3),...
                    marker{2}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
            end
            idx = idx + 1;
        end
    end
end
end

function [comThreeNearestNeighbours, middleIdx, ied] = extractCoM(pointList)
    for i=1:size(pointList,1)
        distances = sqrt(sum((pointList - repmat(pointList(i,:),size(pointList,1),1)).^2,2));
        [~,idx] = sort(distances);
        comThreeNearestNeighbours(i,:) = mean(pointList(idx(1:3),:),1);
        [a, b] = sort(1./((1./pointList(idx(1:3),1))+(1./pointList(idx(1:3),2))));
        middleIdx(i) = idx(b);
        ied(i) = a;
    end
end
