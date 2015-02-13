function job = minicubeFwdPass( parameter )
% classification of subregions within the data set (for segmentation optimization and GP training) 

load(parameter.cnn.first, 'cnet');

for tr=1:length(parameter.local)
	bbox = parameter.local(tr).bboxSmall;
    functionH{tr} = @onlyFwdPass3DonKnossosFolder;
    inputCell{tr} = {cnet, parameter.cnn.GPU, parameter.raw, parameter.local(tr).class, bbox};
end

if parameter.cnn.GPU
	job = startGPU(functionH, inputCell, 'classification');
else
	job = startCPU(functionH, inputCell, 'classification');
end

end
