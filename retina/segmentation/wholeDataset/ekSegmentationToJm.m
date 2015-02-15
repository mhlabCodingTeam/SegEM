function ekSegmentationToJm()

dir = '/path/to/some/directory/results/CNNfwdPass/14-Feb-2013618765/';
jm = findResource('scheduler', 'configuration', 'local_1');
job = createJob(jm, 'configuration', 'local_1');
for i=1:2%36
	for j=1:2%43
		for k=1:2%45
			inputargs = {dir, i-1,j-1,k-1};
			task = createTask(job, @segment_ek_0563ForPaper, 0, inputargs, 'configuration', 'local_1');
		end
	end
end
submit(job);

end

