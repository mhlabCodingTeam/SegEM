function stacks = removeSomaStacks(stacks, excludeTask)

for i=1:length(excludeTask)
	idx = [stacks.taskID] == excludeTask(i);
	stacks(idx) = [];
end

end
