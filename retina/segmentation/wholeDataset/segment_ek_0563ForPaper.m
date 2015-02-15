function segment_ek_0563ForPaper( dir, xCP, yCP, zCP )
% Uses affinity map 5 algo 2 radius 2 pR 2,2 from nov2 parmater scan

overlap = [-64 64; -64 64; -64 64];
% Morphological opening
rT = 1;
folders = {'x/' 'y/' 'z/'};
affReconRecon = cell(3,1);
[x,y,z] = meshgrid(-rT:rT,-rT:rT,-rT:rT);
se = (x/rT).^2 + (y/rT).^2 + (z/rT).^2 <= 1;
for dir=1:length(folders)
    % Decide with region to read in, notice overlap
    bbox = [[xCP;yCP;zCP],[xCP;yCP;zCP] + 1] * 128;
    bbox(:,1) = bbox(:,1) + 1;
    aff = readKnossosRoi([dir folders{dir}], '100527_k0563_seg', bbox + overlap, 'single', '', 'raw');
    % Opening by reconstruction
    affEroded = imerode(aff, se);
    affRecon = imreconstruct(affEroded, aff);
    % Closing by reconstruction
    affReconDilated = imdilate(affRecon, se);
    affReconRecon{dir} = imreconstruct(imcomplement(affReconDilated), imcomplement(affRecon));
end

% Marker generation
fgm1 = (affReconRecon{1} + affReconRecon{2} + affReconRecon{3}) / 3;
fgm1 = fgm1 < .31;
fgm1 = bwareaopen(fgm1, 20, 26);

% Segmentation using Ramin's mex watershed
N_LEVELS = 20000;
N_LEVELS_BOUNDARY = 1;
for dir=1:length(folders)
    mini = min(affReconRecon{dir}(:));
    maxi = max(affReconRecon{dir}(:));
    affReconRecon{dir} = uint16(round((N_LEVELS-1) .* (affReconRecon{dir}-mini)./(maxi-mini)));
end
marker = uint16(labelmatrix(bwconncomp(fgm1)));
seg = watershed_threeTimes3D(affReconRecon{1}, affReconRecon{2}, affReconRecon{3}, marker, N_LEVELS, N_LEVELS - N_LEVELS_BOUNDARY);
writeKnossosCube([dir 'seg/'], '100527_k0563_seg', [xCP,yCP,zCP], seg, 'uint16');

end

