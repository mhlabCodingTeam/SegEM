function plotErrorBinned(data, savingDir, iter)

if ~exist(savingDir, 'dir');
	mkdir(savingDir);
	system(['chmod -R 770 ' savingDir]);
end

figure('Visible', 'off');
for gpu=1:length(data)
	if ~isempty(data(gpu).err)
		meanVal(gpu) = mean(data(gpu).err);
		minVal(gpu) = min(data(gpu).err);
		maxVal(gpu) = max(data(gpu).err);
	end	
end
errorbar([1:length(meanVal)],meanVal,minVal,maxVal);
title(['Error during iteration' num2str(iter, '%.2i') 'sorted by GPU']);

saveas(gcf,[savingDir 'errorRatesGPU' num2str(iter, '%.2i') '.fig']);
saveas(gcf,[savingDir 'errorRatesGPU' num2str(iter, '%.2i') '.png']);
system(['chmod -R 770 ' savingDir]);
end
