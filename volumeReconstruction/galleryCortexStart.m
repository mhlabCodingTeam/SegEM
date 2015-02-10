function galleryCortexStart(p, dataFolder, saveFolder)

skelPath = [dataFolder filesep 'supplement' filesep 'extracted' filesep 'spinyStellateForPaper' filesep];

files = dir([skelPath '*.nml']);

for i=1:length(files)
    functionH{i} = @galleryCortex;
    inputCell{i} = {p, skelPath, files(i).name, saveFolder};
end

startCPU(functionH, inputCell, 'whole cell cortex');

clear files functionH inputCell;

skelPath = [dataFolder filesep 'supplement' filesep 'extracted' filesep 'axonsForPaper' filesep];

files = dir([skelPath '*.nml']);

for i=1:length(files)
    functionH{i} = @galleryCortex;
    inputCell{i} = {p, skelPath, files(i).name, saveFolder};
end

startCPU(functionH, inputCell, 'whole cell cortex');

end

