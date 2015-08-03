layers = [2 3 5 6];
titles = {'First CNN layer' 'Second CNN layer' 'Fifth CNN layer' 'Last CNN layer'};
xlabels = {'w_1_2', 'w_2_3', 'w_4_5', 'w_5_6'};
figure;
for i = 1:4;
    layer = layers(i);
    subplot(4,1,i);
    % SegEM original
    cnet = cnn(4,[10 10 10 10], [10 10 10], train([10 10 10], '/home/mberning/', 1e6, 1e-2, 1e-2), 0, 0, 0, 1);
    cnet = cnet.init;
    weights = cat(4,cnet.layer{layer}.W{:});
    allWeights(:,1) = weights(:);
    % SegEM fan-in
    cnet = cnn(4,[10 10 10 10], [10 10 10], train([10 10 10], '/home/mberning/', 1e6, 1e-2, 1e-2), 1, 0, 0, 1);
    cnet = cnet.init;
    weights = cat(4,cnet.layer{layer}.W{:});
    allWeights(:,2) = weights(:);
    % SegEM fan-out
    cnet = cnn(4,[10 10 10 10], [10 10 10], train([10 10 10], '/home/mberning/', 1e6, 1e-2, 1e-2), 0, 1, 0, 1);
    cnet = cnet.init;
    weights = cat(4,cnet.layer{layer}.W{:});
    allWeights(:,3) = weights(:);
    % SegEM He et al.
    cnet = cnn(4,[10 10 10 10], [10 10 10], train([10 10 10], '/home/mberning/', 1e6, 1e-2, 1e-2), 0, 0, 1, 1);
    cnet = cnet.init;
    weights = cat(4,cnet.layer{layer}.W{:});
    allWeights(:,4) = weights(:);
    hist(allWeights, [-0.0395:0.001:0.0395]);
    legend('SegEM', 'fan-in', 'fan-out', 'He et al.');
    title(titles{i});
    xlabel(['value of ' xlabels{i}]);
    ylabel('# of weights');
    clear allWeights;
end