function visualizeOverviewNodeSizeControl( param, paramTest)

if ~exist([param.dataFolder param.figureSubfolder '/'], 'dir')
    mkdir([param.dataFolder param.figureSubfolder '/']);
end
display('Control Plot Node Size Threshold, see reviewer 2 comment 9');
figure('position', [1 1 1600 785]);
hold on;
[a, b, c, keptSamples1, sampleCoord1] = plotParam(paramTest, [0 0 0], 1);
[d, e, f, keptSamples3, sampleCoord3] = plotParam(paramTest, [0 1 0], 3);
%[g, h, k] = plotParam(paramTest, [1 0 0], 5);
% Added hack, display IED and according parameters
temp = getParamCombinations(param.algo);
temp = cat(1,temp{1}{:});
temp = temp(:,2);
temp = cell2mat(cat(1,temp{:}));
% Plot optimal IEDs
keptSampleCoord1T = squeeze(sampleCoord1(keptSamples1(:,1),1,:));
keptSampleCoord2T = squeeze(sampleCoord1(keptSamples1(:,2),2,:));
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
% Output for parameters etc. of optimal IED
display('Node threshold 1, middle segmentation of 3 NN according to IED:');
display(['IED: ' num2str(ied1(maxID1)) ', Merger: ' num2str(keptSampleCoord1T(idx1(maxID1),1)) ', Split: ' num2str(keptSampleCoord1T(idx1(maxID1),2))]);
display(['Parameter = ' num2str(0) ', ' num2str(temp(idx1(maxID1),1)) ', ' num2str(temp(idx1(maxID1),2))]);
display('Node threshold 2, middle segmentation of 3 NN according to IED:');
display(['IED: ' num2str(ied2(maxID2)) ', Merger: ' num2str(keptSampleCoord2T(idx2(maxID2),1)) ', Split: ' num2str(keptSampleCoord2T(idx2(maxID2),2))]);
display(['Parameter = ' num2str(0) ', ' num2str(temp(idx2(maxID2),1)) ', ' num2str(temp(idx2(maxID2),2))]);
% Plot optimal IEDs
keptSampleCoord1T = squeeze(sampleCoord3(keptSamples3(:,1),1,:));
keptSampleCoord2T = squeeze(sampleCoord3(keptSamples3(:,2),2,:));
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
% Output for parameters etc. of optimal IED
display('Node threshold 1, middle segmentation of 3 NN according to IED:');
display(['IED: ' num2str(ied1(maxID1)) ', Merger: ' num2str(keptSampleCoord1T(idx1(maxID1),1)) ', Split: ' num2str(keptSampleCoord1T(idx1(maxID1),2))]);
display(['Parameter = ' num2str(0) ', ' num2str(temp(idx1(maxID1),1)) ', ' num2str(temp(idx1(maxID1),2))]);
display('Node threshold 2, middle segmentation of 3 NN according to IED:');
display(['IED: ' num2str(ied2(maxID2)) ', Merger: ' num2str(keptSampleCoord2T(idx2(maxID2),1)) ', Split: ' num2str(keptSampleCoord2T(idx2(maxID2),2))]);
display(['Parameter = ' num2str(0) ', ' num2str(temp(idx2(maxID2),1)) ', ' num2str(temp(idx2(maxID2),2))]);
% Formatting of figure
xlabel('average distance between merger [microns]');
ylabel('average distance between splits [microns]');
zlabel('# objects');
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
set(gca, 'XTick', [1e3 1e4 1e5 1e6]);
set(gca, 'XTickLabel', [1 10 100 1000]);
set(gca, 'YTick', [1e2 1e3 1e4 1e5]);
set(gca, 'YTickLabel', [0.1 1 10 100]);
grid off;
legend([a b d e], 'node threshold 1; node size 1', 'node threshold 2; node size 1', 'node threshold 1; node size 3', 'node threshold 2; node size 3');
saveas(gcf, [param.dataFolder param.figureSubfolder filesep 'overviewComparisonNew.fig']);

function [u, v, w, kept, plotted] = plotParam(param, color, nodeSize)
    marker = {'+' 'o' 'x'};
    paramCell = getParamCombinations(param.algo);   
    for i=1:1%only first algo for cortex size(paramCell,2)
        for j=1:length(paramCell{i})
                display([num2str(j, '%.3i') ' of ' num2str(length(paramCell{i}), '%.3i')]);
                load([param.dataFolder param.outputSubfolder  param.affMaps(1).name filesep 'seg' num2str(0) '-' num2str(i) '-' num2str(j) '.mat'], 'v');
                eval1 = evaluateSeg(v, param.skel, 1, nodeSize);
                eval2 = evaluateSeg(v, param.skel, 2, nodeSize);
                kept(j,1) = eval1.split.sum > 1 && eval1.merge.sum > 1;
                kept(j,2) = eval2.split.sum > 1 && eval2.merge.sum > 1;
                plotted(j,1,1) = param.totalPathLength./max(eval1.merge.sum,1);
                plotted(j,1,2) = param.totalPathLength./max(eval1.split.sum,1);
                plotted(j,1,3) = eval1.general.zeroHits./eval1.general.nodesTotal;
                plotted(j,2,1) = param.totalPathLength./max(eval2.merge.sum,1);
                plotted(j,2,2) = param.totalPathLength./max(eval2.split.sum,1);
                plotted(j,2,3) = eval2.general.zeroHits./eval2.general.nodesTotal;
%                 plotted(j,3,1) = param.totalPathLength./max(eval3.merge.sum,1);
%                 plotted(j,3,2) = param.totalPathLength./max(eval3.split.sum,1);
%                 plotted(j,3,3) = eval3.general.zeroHits./eval3.general.nodesTotal;
                %eval3 = evaluateSeg(v, param.skel, 3, nodeSize);
                if kept(j,1)
                    u = plot3(param.totalPathLength./max(eval1.merge.sum,1), param.totalPathLength./max(eval1.split.sum,1), eval1.general.maxNrObjects,...
                        marker{1}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
                end
                if kept(j,2)
                    v = plot3(param.totalPathLength./max(eval2.merge.sum,1), param.totalPathLength./max(eval2.split.sum,1), eval2.general.maxNrObjects,...
                        marker{2}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
                end
                w = [];
                %w = plot3(param.totalPathLength./max(eval3.merge.sum,1), param.totalPathLength./max(eval3.split.sum,1), eval3.general.maxNrObjects,...
                %    marker{3}, 'MarkerEdgeColor', color, 'MarkerSize', 5);
        end
    end
end

end

