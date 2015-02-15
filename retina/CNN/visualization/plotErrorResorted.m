function plotErrorResorted( struct )
%plotError( struct, sizeMovAvg )
%   Plot errors and save to file

colors = {'sr' 'sg' 'sb' 'sy' 'sk' 'sc' 'dr' 'dg' 'db' 'dy' 'dk' 'dc' 'or' 'og' 'ob' 'oy' 'ok' 'oc'};
figure('Visible', 'off');
hold on;

fields = fieldnames(struct);
nrIter = zeros(length(fields),1);
for i=1:length(fields)
    [result, nrIter(i)] = loadCNNResults(['/path/to/some/directory/fermatResults/' struct.(fields{i}).date '/net' num2str(struct.(fields{i}).rand, '%6.6u') '/'], {'error' 'currentStack'});
    [cnet, ~] = loadSingleCNN(['/path/to/some/directory/fermatResults/' struct.(fields{i}).date '/net' num2str(struct.(fields{i}).rand, '%6.6u') '/']);
    maxIterMini = cnet.run.maxIterMini;
    errorMean = zeros(length(result.error),1);
    errorMeanC = zeros(length(result.error),1);
    errorStd = zeros(length(result.error),1);
    errorStdC = zeros(length(result.error),1);
    currentStack = zeros(length(result.currentStack),1);
    temp = zeros(maxIterMini, 1);
    tempC = zeros(maxIterMini, 1);
    for j=1:length(result.error)
        for k=1:length(result.error{j})
            temp(k) = result.error{j}{k}.all;
            tempC(k) = result.error{j}{k}.cutoff;
        end
        temp(isnan(temp)) = [];
        tempC(isnan(tempC)) = [];
        errorMeanC(isnan(errorMeanC)) = 0;
        currentStack(j) = str2double(result.currentStack{j}(48:51));
        errorMean(j) = mean(temp);
        errorMeanC(j) = mean(tempC);
        errorStd(j) = std(temp);
        errorStdC(j) = std(tempC);
    end
    [currentStack, ind] = sort(currentStack);
    current = 0;
    for j=1:length(currentStack)
        if current ~= currentStack(j)
            current = currentStack(j);
            counter = 0;
        else
            counter = counter + 1;
        end
        currentStack(j) = current + counter * 0.1;
    end
    errorMean = errorMean(ind);
    errorMeanC = errorMeanC(ind);
    errorStd = errorStd(ind);
    errorStdC = errorStdC(ind);
    subplot(2,1,1);
    errorbar(currentStack, errorMean, errorStd, colors{i});
    xlim([0 236]);
    grid on; grid minor;
    hold on;
    title('Pixel-Error resorted by cube identity');
    subplot(2,1,2);
    errorbar(currentStack, errorMeanC, errorStdC, colors{i});
    xlim([0 236]);
    grid on; grid minor;
    hold on;
    title('Pixel-Error resorted by cube identity with Cutoff');
end
legend(fields, 'Location', 'BestOutside');

% Save to PDF file in sync folder
set(gcf, 'PaperPosition', [0 0 15 10]);
set(gcf, 'PaperSize', [15 10]);
print('-dpdf', ['/path/to/some/directory/sync/toP1-377/PDF/' struct.(fields{i}).date '/errorR.pdf']);
close all;

end

