function visualizeOverview_2( param )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here            
markerSize = linspace(5,15,length(param.r));
colors = distinguishable_colors(30, [1 1 1]);
marker = {'+' 'o' '*' '.' 'x' 's' 'd' '^' 'v' '>' '<' 'p' 'h'};

if ~exist([param.dataFolder param.figureSubfolder '/'])
    mkdir([param.dataFolder param.figureSubfolder '/']);
end

for map=1:size(param.affMaps,1)
    display(['Overview Detail: CNN # ' num2str(map) '/'  num2str(length(param.affMaps))]);
    tic;
    for algo=1:size(param.algo,2)
        figure('position', [1 1 1600 785], 'Renderer', 'painters');
        la = cell(length(param.r)*size(param.pR{map,algo},1)*size(param.pR{map,algo},2),1);
        for r=1:length(param.r)
            a = load([param.dataFolder param.outputSubfolder param.affMaps(map).name '/evaluation' num2str(r) '-' num2str(algo) '.mat']);
            for i=1:size(a.v.merge,1)
                for j=1:size(a.v.merge,2)
                    plot3(param.totalPathLength/a.v.merge(i,j).sum, param.totalPathLength/a.v.split(i,j).sum, a.v.general(i,j).maxNrObjects, marker{mod(i,13) + 1}, 'MarkerEdgeColor', colors(j,:), 'MarkerSize', markerSize(r));
                    hold on;
                    la{sub2ind([size(a.v.merge,2) size(a.v.merge,1) length(param.r)],j,i,r)} = [num2str(param.r(r), '%i') '-' num2str(param.pR{map,algo}{1}(i), '%4.3f') '-' num2str(param.pR{map, algo}{2}(j), '%4.3f')];
                end
            end
        end
        xlabel('average distance between merger [nm]');
        ylabel('average distance between splits [nm]');
        zlabel('# objects');
        la(cellfun(@isempty,la)) = [];
        legend(la, 'Location', 'BestOutside');
        grid on;
        saveas(gcf, [param.dataFolder param.figureSubfolder '/overview' param.affMaps(map).name '-' num2str(algo) '.fig']);
        close all;
        figure('position', [1 1 1600 785]);
        for r=1:length(param.r)
            if ~isempty(a.v.nodes{1})
%                 b = load([param.dataFolder param.outputSubfolder param.affMaps(map).name '/seg' num2str(r) '-' num2str(algo) '.mat']);
                for i=1:size(a.v.merge,1)
                    for j=1:size(a.v.merge,2)
                        plot3(param.r(r), param.pR{map,algo}{1}(i), param.pR{map,algo}{2}(j), marker{mod(i,13) + 1}, 'MarkerEdgeColor', colors(j,:), 'MarkerSize', markerSize(r));
                        hold on;
                    end
                end
            end
        end
        xlabel('radius of structuring element (rse)');
        ylabel('threshold for marker generation (tmg)');
        zlabel('minimum marker size (mms)');
        la(cellfun(@isempty,la)) = [];
        legend(la, 'Location', 'BestOutside');
        grid on;
        saveas(gcf, [param.dataFolder param.figureSubfolder '/overview' param.affMaps(map).name '-' num2str(algo) 'legend.fig']);
        close all;
    end
    toc
end
    
end

