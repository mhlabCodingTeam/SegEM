function plotError(data, savingDir, iter)

if ~exist(savingDir, 'dir');
	mkdir(savingDir);
	system(['chmod -R 770 ' savingDir]);
end

colors = {'k' 'g' 'r' 'b' 'y' 'c' 'm'};
figure('Visible', 'off');
for gpu=1:length(data)
	plot(data(gpu).err, ['x' colors{mod(gpu,7) + 1}], 'LineWidth', 2);
	hold on;
	legendString{gpu} =  ['GPU: ' num2str(gpu, '%2i')];
end
title(['Error during iteration' num2str(iter, '%.2i')]);
legend(legendString);

saveas(gcf,[savingDir 'errorRates' num2str(iter, '%.2i') '.fig']);
saveas(gcf,[savingDir 'errorRates' num2str(iter, '%.2i') '.png']);
system(['chmod -R 770 ' savingDir]);
end
