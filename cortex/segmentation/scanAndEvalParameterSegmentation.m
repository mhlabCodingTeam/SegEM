function param = scanAndEvalParameterSegmentation( param, currentPar  )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    
    %scan
    a = load([param.dataFolder param.outputSubfolder currentPar.nameAffMap filesep 'MorphRecon' num2str(currentPar.r) '.mat']);
    p1 = currentPar.par(1);
    p2 = currentPar.par(2);

    if currentPar.algoIdx == 1
        segmentation = watershedSeg_v1_cortex(a.v, p1, p2);
    end
    if currentPar.algoIdx == 2
        segmentation = watershedSeg_v2_cortex(a.v, p1, p2);
    end
    if currentPar.algoIdx == 3
        segmentation = watershedSeg_v3_cortex(a.v, p1, p2);
    end
    if currentPar.algoIdx == 4
        segmentation = watershedSeg_v4_cortex(a.v, p1, p2);
    end
    parsave([param.dataFolder param.outputSubfolder filesep currentPar.nameAffMap filesep 'seg' num2str(currentPar.r) '-' num2str(currentPar.algoIdx) '-' num2str(currentPar.par(1)) '-' num2str(currentPar.par(2)) '.mat'], segmentation);

    
    %evaluate
    eval = evaluateSeg(segmentation, param.skel, param.nodeThres);
    parsave([param.dataFolder param.outputSubfolder filesep currentPar.nameAffMap filesep 'evaluation' num2str(currentPar.r) '-' num2str(currentPar.algoIdx) '-' num2str(currentPar.par(1)) '-' num2str(currentPar.par(2)) '.mat'], eval);
            
end