function job = morphScanAndEval( param, nameAffMap, r, fullGrow)

if nargin < 4
    % Classic SegEM behaviour
    fullGrow = false;
end

% Morphological Reconstruction
a = load([param.dataFolder param.affSubfolder nameAffMap '.mat'], 'class');
r = param.r(r);
if r ~= 0
    [x,y,z] = meshgrid(-r:r,-r:r,-r:r);
    se = (x/r).^2 + (y/r).^2 + (z/r).^2 <= 1;
    % Opening by reconstruction
    affEroded = imerode(a.class, se);
    affRecon = imreconstruct(affEroded, a.class);
    % Closing by reconstruction
    affReconDilated = imdilate(affRecon, se);
    affReconRecon = imreconstruct(imcomplement(affReconDilated), imcomplement(affRecon));
else
    affReconRecon = imcomplement(a.class);
end
if ~exist([param.dataFolder param.outputSubfolder nameAffMap filesep], 'dir')
    mkdir([param.dataFolder param.outputSubfolder nameAffMap filesep]);
end
save([param.dataFolder param.outputSubfolder nameAffMap filesep 'MorphRecon' num2str(r) '.mat'], 'affReconRecon');

% scan and eval
paramCell = getParamCombinations(param.algo);
for i=1:size(paramCell,2)
    parfor j=1:length(paramCell{i})
        %scan
        display(j);
        fun = paramCell{i}{j}{1};
        segmentation = fun(affReconRecon,paramCell{i}{j}{2}(:));
        if fullGrow
            segTemp = imdilate(segmentation, ones(3,3,3));
            borders = segmentation == 0;
            segmentation(borders) = segTemp(borders);
        end
        parsave([param.dataFolder param.outputSubfolder nameAffMap filesep 'seg' num2str(r) '-' num2str(i) '-' num2str(j) '.mat'], segmentation);
        %evaluate
        eval = evaluateSeg(segmentation, param.skel, param.nodeThres);
        parsave([param.dataFolder param.outputSubfolder nameAffMap filesep 'evaluation' num2str(r) '-' num2str(i) '-' num2str(j) '.mat'], eval);
    end
end

end
