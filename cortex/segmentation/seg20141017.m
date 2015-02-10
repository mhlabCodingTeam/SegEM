function seg20141017( root, prefix, bbox, saveFile )

% Load classification
aff = loadClassData(root, prefix, bbox);

% Replace this part with routines from segmentation submodule as soon as possible and add all parameter to active->setParameterSettings.m
aff = imcomplement(aff);
fgm1 = imextendedmin(aff, .25, 26);
fgm1 = bwareaopen(fgm1, 10);
map = imimposemin(aff, fgm1);
seg = watershed(map, 26);
seg = uint16(seg);

% Save segmentation to MATLAB file in 'saveFolder'
save(saveFile, 'seg');

end

