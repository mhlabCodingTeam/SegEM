function scanParameterSegmentationCortex( param )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

parfor map=1:size(param.affMaps,1)
    display(['Segmentation: CNN # ' num2str(map) '/'  num2str(size(param.affMaps,1))]);
    tic;
    for r=1:length(param.r)
        a = load([param.dataFolder param.outputSubfolder filesep param.affMaps(map).name filesep 'MorphRecon' num2str(r) '.mat']);
        for algo=1:size(param.algo,2)
            if strcmp(param.algo{algo}, 'v1')
                segmentation = watershedSeg_v1_cortex(a.v, param.pR{map,algo}{1}, param.pR{map,algo}{2});
            end
            if strcmp(param.algo{algo}, 'v2')
                segmentation = watershedSeg_v2_cortex(a.v, param.pR{map,algo}{1}, param.pR{map,algo}{2});
            end
            parsave([param.dataFolder param.outputSubfolder filesep param.affMaps(map).name filesep 'seg' num2str(r) '-' num2str(algo) '.mat'], segmentation);
        end
    end
    toc
end

end

