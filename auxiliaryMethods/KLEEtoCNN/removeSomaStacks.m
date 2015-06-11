function stacks = removeSomaStacks(stacks)

load /zdata/manuel/data/cortex/originalKLEE/exclude.mat;
for i=1:length(excludeTask)
	idx = [stacks.taskID] == excludeTask(i);
	stacks(idx) = [];
end

