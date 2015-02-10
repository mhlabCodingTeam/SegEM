function param = evalParameterSegmentation( param )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

for map=1:size(param.affMaps,1)
    display(['Evaluation: CNN # ' num2str(map) '/'  num2str(size(param.affMaps,1))]);
    tic;
    for r=1:length(param.r)
        for algo=1:size(param.algo,2)
            if exist([param.dataFolder param.outputSubfolder filesep param.affMaps(map).name filesep 'seg' num2str(r) '-' num2str(algo) '.mat'], 'file');
                a = load([param.dataFolder param.outputSubfolder param.affMaps(map).name filesep 'seg' num2str(r) '-' num2str(algo) '.mat']);
                eval = evaluateSeg(a.v, param.skel, param.nodeThres);
                parsave([param.dataFolder param.outputSubfolder filesep param.affMaps(map).name filesep 'evaluation' num2str(r) '-' num2str(algo) '.mat'], eval);
            end
        end
    end
    toc
end

end