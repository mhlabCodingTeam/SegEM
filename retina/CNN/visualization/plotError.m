function plotError( struct, sizeMovAvg )
%plotError( struct, sizeMovAvg )
%   Plot errors and save to file

a = 1;
b = 1/sizeMovAvg*ones(sizeMovAvg,1);
colors = {'r' 'g' 'b' 'y' 'k' 'c' ':r' ':g' ':b' ':y' ':k' ':c' '--r' '--g' '--b' '--y' '--k' '--c' 'r' 'g' 'b' 'y' 'k' 'c' ':r' ':g' ':b' ':y' ':k' ':c' '--r' '--g' '--b' '--y' '--k' '--c'};
figure('Visible', 'off');
hold on;

fields = fieldnames(struct);
nrIter = zeros(length(fields),1);
for i=1:length(fields)
    [result, nrIter(i)] = loadCNNResults(['/zdata/manuel/fermatResults/' struct.(fields{i}).date '/net' num2str(struct.(fields{i}).rand, '%6.6u') '/'], {'error'});
    [cnet, ~] = loadSingleCNN(['/zdata/manuel/fermatResults/' struct.(fields{i}).date '/net' num2str(struct.(fields{i}).rand, '%6.6u') '/']);
    maxIterMini = cnet.run.maxIterMini;
    error = zeros(length(result.error)*maxIterMini,1);
    errorC = zeros(length(result.error)*maxIterMini,1);
    for j=1:length(result.error)
        for k=1:length(result.error{j})
            errorC(k+(j-1)*maxIterMini) = result.error{j}{k}.cutoff;
            error(k+(j-1)*maxIterMini) = result.error{j}{k}.all;
        end
    end
    error(isnan(error)) = 0;
    errorC(isnan(errorC)) = 0;
    subplot(2,1,1);
    plot(filter(b,a,error), colors{i});
    hold on;
    title('Pixel-Error in all Affinity Maps');
    subplot(2,1,2);
    plot(filter(b,a,errorC), colors{i});
    hold on;
    title('Pixel-Error in all Affinity Maps with Cutoff');
end
n = max(nrIter)*maxIterMini;
subplot(2,1,1);
xlim([sizeMovAvg+1 n-sizeMovAvg]);
ylim([-10e-2 10e-2]);
subplot(2,1,2);
xlim([sizeMovAvg+1 n-sizeMovAvg]);
ylim([-10e-2 10e-2]);
legend(fields, 'Location', 'BestOutside');

% Save to PDF file in sync folder
set(gcf, 'PaperPosition', [0 0 15 10]);
set(gcf, 'PaperSize', [15 10]);
print('-dpdf', ['/zdata/manuel/sync/toP1-377/PDF/' struct.(fields{i}).date '/error.pdf']);
close all;

end

