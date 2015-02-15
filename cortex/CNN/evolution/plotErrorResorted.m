function plotErrorResorted(data, savingDir, iter)

if ~exist(savingDir, 'dir');
	mkdir(savingDir);
end

figure('Visible', 'off');
maxMinibatchId = max([data(:).idx]); 
collector = cell(length(data),maxMinibatchId);
for gpu=1:length(data)
	[val, idx] = sort(data(gpu).idx);
	for i=1:length(val)
		collector{gpu, val(i)} = [collector{gpu, val(i)} mean(data(gpu).err(idx(i)))];
	end
end
for i=1:maxMinibatchId
	a.mean(i) = mean([collector{:,i}]);
	a.lower(i) = min([collector{:,i}]);
	a.upper(i) = max([collector{:,i}]); 
end
errorbar(1:maxMinibatchId, a.mean, a.lower, a.upper);
title(['Error sorted according to minibatch for iteration ' num2str(iter, '%.2i')]);
saveas(gcf,[savingDir 'errorRateMinibatches' num2str(iter, '%.2i') '.fig']);
saveas(gcf,[savingDir 'errorRateMinibatches' num2str(iter, '%.2i') '.png']);

end
