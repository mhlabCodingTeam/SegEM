function visualizeOverview( param )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here            
markerSize = linspace(5,15,length(param.r));
marker = {'o' 'x' 'd' '*' '+' 's'};
colors = {'r' 'g' 'b' 'y' 'c' 'm'};

if ~exist([param.dataFolder param.figureSubfolder '/'])
    mkdir([param.dataFolder param.figureSubfolder '/']);
end

figure('Visible', 'off');
la2 = cell(size(param.affMaps,1)*size(param.algo,2)*length(param.r),1);
display('Overview:');
tic;
for map=1:size(param.affMaps,1)
    tic;
    for algo=1:size(param.algo,2)
        for r=1:length(param.r)
            a = load([param.dataFolder param.outputSubfolder param.affMaps(map).name '/evaluation' num2str(r) '-' num2str(algo) '.mat']);
            eval = a.v;
            if ~isempty(eval.nodes{1})
%                 load([param.dataFolder param.outputSubfolder param.affMaps(map).name '/seg' num2str(r) '-' num2str(algo) '.mat']);
                for i=1:size(eval.merge,1)
                    for j=1:size(eval.merge,2)
                        x(i,j) = param.totalPathLength/eval.merge(i,j).sum;
                        y(i,j) = param.totalPathLength/eval.split(i,j).sum;
                        z(i,j) = eval.general(i,j).maxNrObjects;
                    end
                end
                plot3(x(:), y(:), z(:), [marker{map} colors{algo}], 'MarkerSize', markerSize(r));
                hold on;
                la2{sub2ind([length(param.r) length(param.algo) length(param.affMaps)], r, algo, map)} = [num2str(param.r(r), '%i') '-' param.algo{algo} '-' num2str(map, '%i')];
            end
        end
    end
end
toc
xlabel('average distance between merger');
ylabel('average distance between splits');
zlabel('# objects');
la2(cellfun(@isempty,la2)) = [];
legend(la2, 'Location', 'BestOutside');
grid on;
saveas(gcf, [param.dataFolder param.figureSubfolder '/overview.fig']);
close all;


parfor map=1:size(param.affMaps,1)
    display(['Overview Detail: CNN # ' num2str(map) '/'  num2str(length(param.affMaps))]);
    tic;
    for algo=1:size(param.algo,2)
        figure('position', [1 1 1600 785]);
        la = cell(length(param.r)*size(param.pR{map,algo},1)*size(param.pR{map,algo},2),1);
        for r=1:length(param.r)
            a = load([param.dataFolder param.outputSubfolder param.affMaps(map).name '/evaluation' num2str(r) '-' num2str(algo) '.mat']);
            if ~isempty(a.v.nodes{1})
%                 b = load([param.dataFolder param.outputSubfolder param.affMaps(map).name '/seg' num2str(r) '-' num2str(algo) '.mat']);
                for i=1:size(a.v.merge,1)
                    for j=1:size(a.v.merge,2)
                        plot3(param.totalPathLength/a.v.merge(i,j).sum, param.totalPathLength/a.v.split(i,j).sum, a.v.general(i,j).maxNrObjects, [marker{i} colors{j}], 'MarkerSize', markerSize(r));
                        hold on;
                        la{sub2ind([size(a.v.merge,2) size(a.v.merge,1) length(param.r)],j,i,r)} = [num2str(param.r(r), '%i') '-' num2str(param.pR{map,algo}{1}(i), '%4.3f') '-' num2str(param.pR{map, algo}{2}(j), '%4.3f')];
                    end
                end
            end
        end
        xlabel('average distance between merger');
        ylabel('average distance between splits');
        zlabel('# objects');
        la(cellfun(@isempty,la)) = [];
        legend(la, 'Location', 'BestOutside');
        grid on;
        saveas(gcf, [param.dataFolder param.figureSubfolder '/overview' param.affMaps(map).name '-' num2str(algo) '.fig']);
        close all;
    end
    toc
end
    
end

