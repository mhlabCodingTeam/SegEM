function visualizeOverviewNew( param, paramTest )
% Pass param and paramTest from mainSeg.m

if ~exist([param.dataFolder param.figureSubfolder '/'], 'dir')
    mkdir([param.dataFolder param.figureSubfolder '/']);
end
display('Overview: Split-merger segmentation parameter grid search');
figure('position', [1 1 1600 785]);
hold on;
[d, keptSamples, sampleCoord, params] = plotParam(paramTest);
% CORTEX 
% Plot optimal IEDs
keptSampleCoord1T = squeeze(sampleCoord(keptSamples(:,1),1,:));
% Group 3 NN
[keptSampleCoord1, idx1, ied1] = extractCoM(keptSampleCoord1T);
tempIED1 = 1./(1./keptSampleCoord1(:,1)+1./keptSampleCoord1(:,2));
[maxVal1, maxID1] = max(tempIED1);
X = [keptSampleCoord1(maxID1,1)];
Y = [keptSampleCoord1(maxID1,2)];
Z = [keptSampleCoord1(maxID1,3)];
k = plot3(X,Y,Z, '*g', 'LineWidth', 2);
text(X(1),Y(1),['\leftarrow optimal IED: ' num2str(maxVal1/1000, '%3.2f') 'microns']);
% Output for parameters etc. of optimal IED
display('Node threshold 1, middle segmentation of 3 NN according to IED:');
display(['IED: ' num2str(ied1(maxID1)) ', Merger: ' num2str(keptSampleCoord1T(idx1(maxID1),1)) ', Split: ' num2str(keptSampleCoord1T(idx1(maxID1),2))]);
display(['Parameter: r=' num2str(params{maxID1}{1}) ', algo=' num2str(params{maxID1}{2}) ', t/h=' num2str(params{maxID1}{3}) ', ' num2str(params{maxID1}{4})]);
% Formatting
xlabel('average distance between merger [microns]');
ylabel('average distance between splits [microns]');
zlabel('number segmentation objects');
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
set(gca, 'XTick', [1e4 1e5 1e6]);
set(gca, 'XTickLabel', [10 100 1000]);
set(gca, 'YTick', [1e3 1e4 1e5]);
set(gca, 'YTickLabel', [1 10 100]);
grid off;
legend([d{1,1} d{1,2} d{2,1} d{2,2} d{3,1} d{3,2} k], ...
    'cortex test, hmin, r=0', 'cortex test, threshold, r=0',...
    'cortex test, hmin, r=1', 'cortex test, threshold, r=1',...
    'cortex test, hmin, r=2', 'cortex test, threshold, r=2',...
    'cortex best inter-error of 3 NN');
saveas(gcf, [param.dataFolder param.figureSubfolder filesep 'overviewComparisonNew3LAZH.fig']);
end

function [u, kept, plotted, params] = plotParam(param)
marker = {'+' 'o' 'x'};
color = [1 0 0; 0 1 0];
paramCell = getParamCombinations(param.algo);
idx = 1;
for r=1:length(param.r)
    for i=1:size(paramCell,2)
        for j=1:length(paramCell{i})
            load([param.dataFolder param.outputSubfolder  param.affMaps(1).name filesep 'seg' num2str(param.r(r)) '-' num2str(i) '-' num2str(j) '.mat'], 'v');
            eval1 = evaluateSeg(v, param.skel, 1, 1);
            kept(idx,1) = eval1.split.sum > 1 && eval1.merge.sum > 1;
            plotted(idx,1,1) = param.totalPathLength./max(eval1.merge.sum,1);
            plotted(idx,1,2) = param.totalPathLength./max(eval1.split.sum,1);
            plotted(idx,1,3) = eval1.general.maxNrObjects;
            params{idx} = {param.r(r) i paramCell{i}{j}{2}{1} paramCell{i}{j}{2}{2}};
            if kept(idx,1)
                u{r,i} = plot3(plotted(idx,1,1), plotted(idx,1,2), plotted(idx,1,3),...
                    marker{r}, 'MarkerEdgeColor', color(i,:), 'MarkerSize', 5);
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
        middleIdx(i) = idx(b(2));
        ied(i) = a(2);
    end
end
