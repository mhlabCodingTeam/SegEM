function out = selectFilesHD(files)

for i=1:length(files)
	param = regexp(files(i).name(1:end-4), '\_', 'split');
	out(i).taskID = str2num(param{2});
	out(i).lastUpload = 1;
	out(i).tracer = str2num(param{3});
	out(i).filename = files(i).name;
end

end	

