function out = selectFiles(files)
% ALmost obsolete function, for full version see manuelCode repo (only
% makes sense in combination with braintracing DB @braintracing.de)

for i=1:length(files)
	param = regexp(files(i).name(1:end-4), '\_', 'split');
	out(i).dataset = param{1};
	out(i).taskID = str2double(param{2});
	out(i).user = param{3};
    out(i).filename = files(i).name;
end

end	

