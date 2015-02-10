function contactDetectionCortexStart(p, dataFolder, saveFolder)

pathPre = [dataFolder filesep 'supplement' filesep 'extracted' filesep 'axonsForPaper' filesep];
pathPost = [dataFolder filesep 'supplement' filesep 'extracted' filesep 'spinyStellateForPaper' filesep];
filesPre = dir([pathPre '*.nml']);
filesPost = dir([pathPost '*.nml']);

for i=1:length(filesPre)
    for j=1:length(filesPost)
        idx = sub2ind([length(filesPre) length(filesPost)], i, j);
        functionH{idx} = @contactDetectionCortex;
        inputCell{idx} = {p [pathPre filesPre(i).name] [pathPost filesPost(j).name] [saveFolder filesPre(i).name(1:end-4) 'TO' filesPost(j).name(1:end-4) '.nml']};
    end
end

startCPU(functionH, inputCell, 'cortex gallery full');

end
