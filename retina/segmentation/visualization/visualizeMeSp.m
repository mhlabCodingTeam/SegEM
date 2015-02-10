function visualizeMeSp( merge, split, length )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
markerSize = linspace(5,15,size(merge,3));
marker = {'o' 'x' '.' '*' '+' 's' 'd'};
colors = {'r' 'g' 'b' 'y' 'c' 'm' 'k'};
la = cell(numel(merge),1);
figure('position', [1 41 1600 784]);
for i=1:size(merge,1)
    for j=1:size(merge,2)
        for k=1:size(merge,3)
            plot(length/merge(i,j,k).sum, length/split(i,j,k).sum, [marker{i} colors{j}], 'MarkerSize', markerSize(k));
            hold on;
            la{sub2ind(size(merge),i,j,k)} = [num2str(i, '%i') num2str(j, '%i') num2str(k, '%i')];
            xlabel('# average microns between merger');
            ylabel('# average microns between splits');
        end
    end
end
legend(la, 'Location', 'BestOutside');

end

