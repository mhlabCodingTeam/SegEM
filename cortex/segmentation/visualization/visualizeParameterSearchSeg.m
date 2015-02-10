function visualizeParameterSearchSeg(pT, psValues);
    % Visualize all split merger curves for cortex from one parameter sweep

    % Normal
    plotParameterSweep(pT, psValues, 'trainFileLocal');
    % Split merger rates without glia
    plotParameterSweep(pT, psValues, 'trainFileLocalWithoutGlia');

end

function plotParameterSweep(pT, psValues, skelFileFieldName)
    for localIdx=1:length(pT.local)
        skel{localIdx} = parseNml(pT.local(localIdx).(skelFileFieldName));
        pathLength(localIdx) = getPathLength(skel{localIdx});
    end
    colors = distinguishable_colors(length(pT.local)); % For 3 different training regions
    marker = {'+' 'o' 'x'}; % For 3 different node thresholds
    figure('position', [1 1 1600 1200], 'Visible', 'off');
    hold on;
    for localIdx=1:length(pT.local)
        pL = pathLength(localIdx);
        for radiusIdx=1:length(psValues.r)
            for parVar=1:length(psValues.paramCell)
                segFile = [psValues.outputFolder filesep 'seg-' num2str(localIdx) '-' num2str(radiusIdx) '-' num2str(parVar) '.mat'];
                load(segFile);
                eval1 = evaluateSeg(segmentation, skel{localIdx}, 1);
                eval2 = evaluateSeg(segmentation, skel{localIdx}, 2);
                eval3 = evaluateSeg(segmentation, skel{localIdx}, 3);
                figHandle(localIdx,1) = plot3(pL./max(eval1.merge.sum,1), pL./max(eval1.split.sum,1), pL./max(eval1.general.maxNrObjects,1), ...
                    marker{1}, 'MarkerEdgeColor', colors(localIdx,:), 'MarkerSize', 5, 'UserData', [psValues.paramCell{parVar}{2}{:}]);
                figHandle(localIdx,2) = plot3(pL./max(eval2.merge.sum,1), pL./max(eval2.split.sum,1), pL./max(eval2.general.maxNrObjects,1), ...
                    marker{2}, 'MarkerEdgeColor', colors(localIdx,:), 'MarkerSize', 5, 'UserData', [psValues.paramCell{parVar}{2}{:}]);
                figHandle(localIdx,3) = plot3(pL./max(eval3.merge.sum,1), pL./max(eval3.split.sum,1), pL./max(eval3.general.maxNrObjects,1), ...
                    marker{3}, 'MarkerEdgeColor', colors(localIdx,:), 'MarkerSize', 5, 'UserData', [psValues.paramCell{parVar}{2}{:}]);
                figLegend{localIdx,1} = ['denseRegion' num2str(localIdx) ' with node threshold 1'];
                figLegend{localIdx,2} = ['denseRegion' num2str(localIdx) ' with node threshold 2'];
                figLegend{localIdx,3} = ['denseRegion' num2str(localIdx) ' with node threshold 3'];
            end
        end
    end
    xlabel('average path length between merger [nm]');
    ylabel('average path length between splits [nm]');
    zlabel('average path length per object');
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    set(gca, 'ZScale', 'log');
    grid on;
    xlim([5e3 1e6]); % Will need to be reset for different dataset training data, necessary for easier comparison of results
    ylim([5e2 5e3]); % this is comparison with and without glia neurites
    legend(figHandle(:), figLegend(:), 'Location', 'EastOutside');
    view(3);
    saveas(gcf, [psValues.outputFolder skelFileFieldName '.fig']);
    set(gcf, 'PaperPositionMode', 'auto');
    set(gcf,'PaperSize',fliplr(get(gcf,'PaperSize')));
    view(0,90);
    print([psValues.outputFolder skelFileFieldName '_xy.pdf'], '-dpdf');
    view(0,0);
    print([psValues.outputFolder skelFileFieldName '_xz.pdf'], '-dpdf');

end

