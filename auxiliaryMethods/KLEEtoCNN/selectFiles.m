function out = selectFiles(files)

for i=1:length(files)
    param = regexp(files(i).name(1:end-4), '\_', 'split');
    dataset(i) = str2num(param{1});
    tasktype(i) = str2num(param{2});
    task(i) = str2num(param{3});
    user{i} = param{4};
    upload(i) = str2num(param{5}(1:3));
end

if any(dataset ~= 3)
    warning('Wrong dataset ID included');
end

if any(tasktype ~= 15)
    warning('Wrong tasktype ID included');
end

uniqueTasks = unique(task);
for i=1:length(uniqueTasks);
    idxTasks = task == uniqueTasks(i);
    uploads = upload .* idxTasks;
    [lastUpload, idxMaxUpload] = max(uploads);
    out(i).taskID = uniqueTasks(i);
    out(i).lastUpload = lastUpload;
    out(i).tracer = user{idxMaxUpload};
    out(i).filename = files(idxMaxUpload).name;
end

