function visualizeOverview_2( param )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here            
markerSize = linspace(5,15,length(param.r));
load(param.cmSource);
marker = {'+' 'o' '*' '.' 'x' 's' 'd' '^' 'v' '>' '<' 'p' 'h'};

if ~exist([param.dataFolder param.figureSubfolder '/'])
    mkdir([param.dataFolder param.figureSubfolder '/']);
end

figure('Visible', 'off');
la2 = cell(size(param.affMaps,1)*size(param.algoIdx,2)*length(param.r),1);
for map=1:size(param.affMaps,1)
    tic;
    for algo=1:size(param.algoIdx,2)
        for r=1:length(param.r)
            totalNrParam = length(param.pR{map,param.algoIdx(algo)}(1))*length(param.pR{map,param.algoIdx(algo)}(2));
            for par = 1:totalNrParam
                [par1 par2] = ind2sub([length(param.pR{map,param.algoIdx(algo)}(1)) length(param.pR{map,param.algoIdx(algo)}(2))], par);
                a = load([param.dataFolder param.outputSubfolder param.affMaps(map).name '/evaluation' num2str(r) '-' num2str(param.algoIdx(algo)) '-' num2str(par1) '-' num2str(par2) '.mat']);
                eval(par1,par2) = a.v;
            end
            for i=1:size(eval,1)
                for j=1:size(eval,2)
                    x(i,j) = param.totalPathLength/eval(i,j).merge.sum;
                    y(i,j) = param.totalPathLength/eval(i,j).split.sum;
                    z(i,j) = eval(i,j).general.maxNrObjects;
                end
            end
            plot3(x(:), y(:), z(:), [marker{mod(map,13) + 1} autoKLEE_colormap(param.algoIdx(algo),:)], 'MarkerSize', markerSize(r));
            hold on;
            la2{sub2ind([length(param.r) length(param.algoIdx) length(param.affMaps)], r, algo, map)} = [num2str(param.r(r), '%i') '-' param.algoIdx(algo) '-' num2str(map, '%i')];
        end
    end
end
xlabel('average nm between merger');
ylabel('average nm between splits');
zlabel('# objects');
la2(cellfun(@isempty,la2)) = [];
legend(la2, 'Location', 'BestOutside');
grid on;
saveas(gcf, [param.dataFolder param.figureSubfolder '/overview.fig']);
close all;


for map=1:size(param.affMaps,1)
    display(['Overview Detail: CNN # ' num2str(map) '/'  num2str(length(param.affMaps))]);
    tic;
    for algo=1:size(param.algoIdx,2)
        figure('position', [1 1 1600 785]);
        la = cell(length(param.r)*size(param.pR{map,param.algoIdx(algo)},1)*size(param.pR{map,param.algoIdx(algo)},2),1);
        for r=1:length(param.r)
            totalNrParam = length(param.pR{map,param.algoIdx(algo)}{1})*length(param.pR{map,param.algoIdx(algo)}{2});
            for par = 1:totalNrParam
                [par1 par2] = ind2sub([length(param.pR{map,param.algoIdx(algo)}{1}) length(param.pR{map,param.algoIdx(algo)}{2})], par);
                a(par1,par2) = load([param.dataFolder param.outputSubfolder param.affMaps(map).name '/evaluation' num2str(r) '-' num2str(param.algoIdx(algo))  '-' num2str(par1) '-' num2str(par2) '.mat']);
            end
            for i=1:size(a,1)
                for j=1:size(a,2)
                    plot3(param.totalPathLength/a(i,j).v.merge.sum/1000, param.totalPathLength/a(i,j).v.split.sum/1000, a(i,j).v.general.maxNrObjects, marker{mod(i,13) + 1}, 'MarkerEdgeColor', autoKLEE_colormap(j,:), 'MarkerSize', markerSize(r));
                    hold on;
                    la{sub2ind([size(a,2) size(a,1) length(param.r)],j,i,r)} = [num2str(param.r(r), '%i') '-' num2str(param.pR{map,param.algoIdx(algo)}{1}(i), '%4.3f') '-' num2str(param.pR{map, param.algoIdx(algo)}{2}(j), '%4.3f')];
                end
            end
        end
        xlabel('average distance between merger [$\mu$m]', 'interpreter', 'latex');
        ylabel('average distance between splits [$\mu$m]', 'interpreter', 'latex');
        zlabel('# objects');
        la(cellfun(@isempty,la)) = [];
        legend(la, 'Location', 'BestOutside');
        grid on;
        saveas(gcf, [param.dataFolder param.figureSubfolder '/overview' param.affMaps(map).name '-' num2str(param.algoIdx(algo)) '.fig']);
        close all;
        figure('position', [1 1 1600 785]);
        for r=1:length(param.r)
            for i=1:size(a,1)
                for j=1:size(a,2)
                    plot3(param.r(r), param.pR{map,param.algoIdx(algo)}{1}(i), param.pR{map,param.algoIdx(algo)}{2}(j), marker{mod(i,13) + 1}, 'MarkerEdgeColor', autoKLEE_colormap(j,:), 'MarkerSize', markerSize(r));
                    hold on;
                end
            end
        end
        xlabel('radius of structuring element (rse)');
        ylabel('threshold for marker generation (tmg)');
        zlabel('minimum marker size (mms)');
        la(cellfun(@isempty,la)) = [];
        legend(la, 'Location', 'BestOutside');
        grid on;
        saveas(gcf, [param.dataFolder param.figureSubfolder '/overview' param.affMaps(map).name '-' num2str(param.algoIdx(algo)) 'legend.fig']);
        close all;
    end
    toc
end
    
end

