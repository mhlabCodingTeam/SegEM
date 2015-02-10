function cnet = loadLastCNN( cnet )
% Load last saved CNN (useful if e.g. CNN got trained over jobmanager and
% direct pointer to CNN is therfore not availible

if exist(cnet.run.savingPath, 'dir')
	files = dir([cnet.run.savingPath '*.mat']);
	if isempty(files)
		warning(['No CNN found: ' cnet.run.savingPath]);
	else
		idx = length(files);
		while true
			try
				a = load([cnet.run.savingPath files(idx).name]);
				cnet = a.cnet;
				break;
			catch
				warning(['Corrupt file: ' cnet.run.savingPath files(idx).name]);
				idx = idx - 1;
				if idx == 0
					break;
				end
			end
		end
	end
else
	warning(['Directory does not exist: ' cnet.run.savingPath]);
end

end

