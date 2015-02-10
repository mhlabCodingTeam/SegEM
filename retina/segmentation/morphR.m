function morphR( param )

parfor map=1:size(param.affMaps,1)
    display(['Morphological Reconstruction: CNN # ' num2str(map) '/'  num2str(size(param.affMaps,1))]);
    tic;
    a = load([param.dataFolder param.affSubfolder param.affMaps(map).name '.mat'], 'affX', 'affY', 'affZ');
    aff = {a.affX a.affY a.affZ};
    affReconRecon = cell(length(aff),1);
    for r=1:length(param.r)
        rT = param.r(r);
        for dir=1:length(aff)
            if rT ~= 0
                [x,y,z] = meshgrid(-rT:rT,-rT:rT,-rT:rT);
                se = (x/rT).^2 + (y/rT).^2 + (z/rT).^2 <= 1;
                % Opening by reconstruction
                affEroded = imerode(aff{dir}, se);
                affRecon = imreconstruct(affEroded, aff{dir});
                % Closing by reconstruction
                affReconDilated = imdilate(affRecon, se);
                affReconRecon{dir} = imreconstruct(imcomplement(affReconDilated), imcomplement(affRecon));
%                 affReconRecon{dir} = imcomplement(affReconRecon{dir});
            else
                affReconRecon{dir} = imcomplement(aff{dir});
            end
        end
        if ~exist([param.dataFolder param.outputSubfolder param.affMaps(map).name '/'], 'dir')
            mkdir([param.dataFolder param.outputSubfolder param.affMaps(map).name '/']);
        end
        parsave([param.dataFolder param.outputSubfolder param.affMaps(map).name filesep 'MorphRecon' num2str(r) '.mat'], affReconRecon);
    end
    toc
end


end

