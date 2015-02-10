function contactDetectionRetinaStart()

outputDir = '/zdata/manuel/sync/wholeCell/contactDetection/full/';
pathBP = '/zdata/manuel/sync/fromLap/ekSkel/full/bpc/';
pathGC = '/zdata/manuel/sync/fromLap/ekSkel/full/gcl/';
filesBP = dir([pathBP '*.nml']);
filesGC = dir([pathGC '*.nml']);

for i=1:length(filesBP)
    for j=1:length(filesGC)
        idx = sub2ind([length(filesBP) length(filesGC)], i, j);
        functionH{idx} = @contactDetectionRetina;
        inputCell{idx} = {[pathBP filesBP(i).name] [pathGC filesGC(j).name] [outputDir filesBP(i).name(1:end-4) 'TO' filesGC(j).name(1:end-4) '.nml']};
    end
end

startCPU(functionH, inputCell, 'retina contact detection full');

end

