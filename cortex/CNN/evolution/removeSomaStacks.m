function stacks = removeSomaStacks(stacks, stackDir)

a = load(stackDir);
for i=1:length(a.excludeTask)
	idx = [stacks.taskID] == excludeTask(i);
	stacks(idx) = [];
end

end
