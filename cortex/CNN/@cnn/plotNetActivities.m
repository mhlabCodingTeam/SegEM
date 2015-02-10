function plotNetActivities( cnet, stacks )
% Visualize transformation by net (e.g. input, output, target)

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
target = single(target);

% Run fwdPass
activity = cnet.onlyFwdPass3D(raw);
   
% Plot final + target*mask + raw
figure('Visible', 'off');
colormap('gray');
a = size(raw);
subplot(1,3,1);
imagesc(raw(1+cnet.randOfConvn(1)/2:end-cnet.randOfConvn(1)/2,1+cnet.randOfConvn(2)/2:end-cnet.randOfConvn(2)/2,cnet.randOfConvn(3)/2+50));
axis equal;
axis off;
if cnet.normalize
	caxis([-3 3]);
else
	caxis([40 210]);
end
title('Raw');

subplot(1,3,2);
imagesc(activity(:,:,50));
axis equal;
axis off;
caxis([-1.7, 1.7]);
title('Affinity');
 
subplot(1,3,3);
imagesc(target(:,:,50));
axis equal;
axis off;
caxis([-1.7 1.7]);
title('Target');
  
if ~exist(cnet.run.savingPath, 'dir');
	mkdir(cnet.run.savingPath);
	system(['chmod -R 770 ' cnet.run.savingPath]);
end

saveas(gcf, [cnet.run.savingPath 'netActivity.fig']);
saveas(gcf, [cnet.run.savingPath 'netActivity.pdf']);
system(['chmod -R 770 ' cnet.run.savingPath]);
close all;

end

