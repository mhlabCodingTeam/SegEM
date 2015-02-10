function morphologicalReconstruction(classParam, bbox, r, outputFile)

    % Morphological Reconstruction
    classification = loadClassData(classParam.root,classParam.prefix,bbox);
    if r ~= 0
        [x,y,z] = meshgrid(-r:r,-r:r,-r:r);
        se = (x/r).^2 + (y/r).^2 + (z/r).^2 <= 1;
        % Opening by reconstruction
        affEroded = imerode(classification, se);
        affRecon = imreconstruct(affEroded, classification);
        % Closing by reconstruction
        affReconDilated = imdilate(affRecon, se);
        affReconRecon = imreconstruct(imcomplement(affReconDilated), imcomplement(affRecon));
    else
        affReconRecon = imcomplement(classification);
    end
   save(outputFile, 'affReconRecon');

end

