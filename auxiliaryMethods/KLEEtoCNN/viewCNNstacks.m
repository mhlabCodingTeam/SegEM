function viewCNNstacks(folder, number)

load(['/zdata/manuel/data/cortex/' folder '/parameter.mat']);
a = load(stacks(number).targetFile);
raw = a.raw;
target = a.target;
load(stacks(number).stackFile);
raw =  raw(1+settings.border(1):end-settings.border(1),1+settings.border(2):end-settings.border(2),1+settings.border(3):end-settings.border(3));
param = stacks(number);
save(['/zdata/manuel/sync/trainingData/' folder 'stack' num2str(number, '%.3i') '.mat'], 'raw', 'target', 'stack', 'param');

end

