function visualizeOverview( param )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here            
markerSize = linspace(5,15,length(param.r));
cm = distinguishable_colors(100,[0 0 0; 1 1 1]);
marker = {'+' 'o' '*' '.' 'x' 's' 'd' '^' 'v' '>' '<' 'p' 'h'};
paramCell = getParamCombinations(param.algo);

if ~exist([param.dataFolder param.figureSubfolder '/'])
    mkdir([param.dataFolder param.figureSubfolder '/']);
end

figure;
la2 = cell(size(param.affMaps,1)*length(param.algo)*length(param.r),1);
for map=1:size(param.affMaps,1)
    for r=1:length(param.r)
        for algo=1:size(paramCell,2)
            for par=1:length(paramCell{algo})
                a = load([param.dataFolder param.outputSubfolder param.affMaps(map).name filesep 'evaluation' num2str(param.r(r)) '-' num2str(algo) '-' num2str(par) '.mat']);
                x(par) = param.totalPathLength/a.v.merge.sum;
                y(par) = param.totalPathLength/a.v.split.sum;
                z(par) = a.v.general.maxNrObjects;
            end
            plot3(x, y, z, marker{mod(map,13) + 1}, 'Color', cm(algo,:), 'MarkerSize', markerSize(r));
            hold on;
            la2{sub2ind([length(param.r) length(param.algo) length(param.affMaps)], r, algo, map)} = [num2str(param.r(r), '%i') '-' num2str(algo, '%i') '-' num2str(map, '%i')];       
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
    for algo=1:size(paramCell,2)
        figure('position', [1 1 1600 785]);
        la = cell(length(param.r)*length(paramCell{algo}),1);
        for r=1:length(param.r)
            for par = 1:length(paramCell{algo})
                a = load([param.dataFolder param.outputSubfolder param.affMaps(map).name filesep 'evaluation' num2str(param.r(r)) '-' num2str(algo) '-' num2str(par) '.mat']);
                % markers: 
                plot3(param.totalPathLength/a.v.merge.sum/1000, param.totalPathLength/a.v.split.sum/1000, a.v.general.maxNrObjects, marker{mod(floor(par./length(paramCell{algo}{par}{2})),13) + 1}, 'MarkerEdgeColor', cm(algo,:), 'MarkerSize', markerSize(r));
                hold on;
                la{sub2ind([length(paramCell{algo}) length(param.r)],par,r)} = [num2str(param.r(r), '%i') '-' printParams(paramCell{algo}{par}{2})];
            end
            
        end
        xlabel('average distance between merger [$\mu$m]', 'interpreter', 'latex');
        ylabel('average distance between splits [$\mu$m]', 'interpreter', 'latex');
        zlabel('# objects');
        la(cellfun(@isempty,la)) = [];
        legend(la, 'Location', 'BestOutside');
        grid on;
        saveas(gcf, [param.dataFolder param.figureSubfolder '/overview' param.affMaps(map).name '-' num2str(algo) '.fig']);
        close all;
    end
    toc;
end


    function string = printParams(cell)
        string = '';
        for i=1:length(cell)
            if(i~=1)
                string = [string '-'];
            end     
            string = [string num2str(cell{i})]; 
        end
    end

end

