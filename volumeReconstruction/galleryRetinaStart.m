function galleryRetinaStart(inputFolder,outputFolder, seg)

preFolder = [inputFolder filesep 'supplement' filesep 'extracted' filesep 'bpc' filesep];

files = dir([preFolder '*.nml']);

functionH = cell(length(files),1);
inputCell = cell(length(files),1);
for i=1:length(files)
    functionH{i} = @galleryRetina;
	inputCell{i} = {preFolder, files(i).name, outputFolder, seg};
end

startCPU(functionH, inputCell, 'gallery retina');

clear functionH inputCell files;

postFolder = [inputFolder filesep 'supplement' filesep 'extracted' filesep 'gcl' filesep];

files = dir([postFolder '*.nml']);

functionH = cell(length(files),1);
inputCell = cell(length(files),1);
for i=1:length(files)
    functionH{i} = @galleryRetina;
	inputCell{i} = {postFolder, files(i).name, outputFolder, seg};
end

startCPU(functionH, inputCell, 'gallery retina');

end

