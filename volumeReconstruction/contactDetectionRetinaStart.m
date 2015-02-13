function contactDetectionRetinaStart(inputFolder, outputDir, seg)

pathBP = [inputFolder filesep 'supplement' filesep 'extracted' filesep 'bpc' filesep];
pathGC = [inputFolder filesep 'supplement' filesep 'extracted' filesep 'gcl' filesep];
filesBP = dir([pathBP '*.nml']);
filesGC = dir([pathGC '*.nml']);

for i=1:length(filesBP)
    for j=1:length(filesGC)
        idx = sub2ind([length(filesBP) length(filesGC)], i, j);
        functionH{idx} = @contactDetectionRetina;
        inputCell{idx} = {[pathBP filesBP(i).name] [pathGC filesGC(j).name] [outputDir filesBP(i).name(1:end-4) 'TO' filesGC(j).name(1:end-4) '.nml'] seg};
    end
end

startCPU(functionH, inputCell, 'retina contact detection full');

end

