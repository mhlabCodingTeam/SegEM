function jobs = miniSegmentation(parameter)

for i=1:size(parameter.local,1)
	for j=1:size(parameter.local,2)
		for k=1:size(parameter.local,3)
			if ~exist(parameter.local(i,j,k).saveFolder, 'dir')
				mkdir(parameter.local(i,j,k).saveFolder);
			end
			idx = sub2ind(size(parameter.local), i, j, k);
			functionH{idx} = parameter.seg.func;
			if isfield(parameter.local(i,j,k), 'class')
				inputCell{idx} = {parameter.local(i,j,k).class.root parameter.local(i,j,k).class.prefix, parameter.local(i,j,k).bboxSmall, parameter.local(i,j,k).segFile};
			else
				inputCell{idx} = {parameter.class.root parameter.class.prefix, parameter.local(i,j,k).bboxBig, parameter.local(i,j,k).segFile};
			end
		end
	end
end

jobs = startCPU(functionH, inputCell, 'segmentation');

end

