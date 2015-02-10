function plotNetActivitiesFull( cnet, stacks )
% Plot activities in all layers

% Set stack to classify
stackNr = 1;
% Load cubes into array
load(stacks(stackNr).targetFile);
borderRaw = ([100 100 50] - cnet.randOfConvn)/2;
if cnet.normalize
	raw = normalizeStack(single(raw(1+borderRaw(1):end-borderRaw(1),1+borderRaw(2):end-borderRaw(2),1+borderRaw(3):end-borderRaw(3))));;
else
	raw = single(raw);
end

% Run fwdPass
activity = cnet.fwdPass3D(raw);
   
% Plot final + target*mask + raw
figure('Visible', 'off');
colormap('gray');
a = size(raw);
for i=1:size(activity,1);
	for j=1:size(activity,2)
	    if ~isempty(activity{i,j});
            subplot(size(activity,2),size(activity,1),i+size(activity,1)*(j-1));
            imagesc(activity{i,j}(1+(6-i)*(cnet.filterSize(1)-1)/2:end-(6-i)*(cnet.filterSize(1)-1)/2, ... % quick hack, replace 6 by size(sth) if different from 4 hidden layers
                1+(6-i)*(cnet.filterSize(2)-1)/2:end-(6-i)*(cnet.filterSize(2)-1)/2,(6-i)*(cnet.filterSize(3)-1)/2+50));
            axis equal;
            axis off;
            caxis([-1.7 1.7]);
	    end
	end
end
 
if ~exist(cnet.run.savingPath, 'dir');
	mkdir(cnet.run.savingPath);
	system(['chmod -R 770 ' cnet.run.savingPath]);
end

saveas(gcf, [cnet.run.savingPath 'netActivityFull.fig']);
saveas(gcf, [cnet.run.savingPath 'netActivityFull.pdf']);
system(['chmod -R 770 ' cnet.run.savingPath]);
close all;

end

