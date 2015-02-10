function galleryRetinaStart(inputFolder,outputFolder)
% Pass inputFolder (location of .nml to be volume segmented
% and outputFolder (location of .issf of volume reconstructions

files = dir([inputFolder '*.nml']);

functionH = cell(length(files),1);
inputCell = cell(length(files),1);
for i=1:length(files)
    functionH{i} = @galleryRetina;
	inputCell{i} = {inputFolder, files(i).name, outputFolder};
end

startCPU(functionH, inputCell, 'gallery retina');

end

