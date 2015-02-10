function job = bigFwdPass( parameter, bboxOutput )
% do the whole classifcation for structure 

load(parameter.cnn.first, 'cnet');

% If only one argument is supplied use bbox from parameter file and add tile border to be able to do segmentation with big field of view for games
if nargin == 1
	bbox = parameter.bbox + parameter.tileBorder;
else
	bbox = bboxOutput;
end

cubeSize = [256 256 128]; % This is not of any importance due to CNN translation invariance, can be choosen for computational efficency, currenlty optimized for running on GPU with 6GB, should be multiples of 128
X = bbox(1,1):cubeSize(1):bbox(1,2)+1;
Y = bbox(2,1):cubeSize(2):bbox(2,2)+1;
Z = bbox(3,1):cubeSize(3):bbox(3,2)+1;
for i=1:length(X)-1
    for j=1:length(Y)-1
        for k=1:length(Z)-1
	        idx = sub2ind([length(X)-1 length(Y)-1 length(Z)-1], i, j, k);
            functionH{idx} = @onlyFwdPass3DonKnossosFolder;
            inputCell{idx} = {cnet, parameter.cnn.GPU, parameter.raw, parameter.class, [X(i) X(i+1)-1; Y(j) Y(j+1)-1; Z(k) Z(k+1)-1]};
        end
    end
end

if parameter.cnn.GPU
	job = startGPU(functionH, inputCell, 'classification');
else
	job = startCPU(functionH, inputCell, 'classification');
end

end

