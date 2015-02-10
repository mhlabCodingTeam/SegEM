%% Classification of training regions
minicubeFwdPass(pT);

% Create directory for segmentation parameter search input (CNN
% classification results)
if ~exist([dataDirectory filesep 'segOptCortex' filesep 'aff' filesep], 'dir')
    mkdir([dataDirectory filesep 'segOptCortex' filesep 'aff' filesep]);
end

% Save for mainSegCortex (raw and classification data both):
raw = readKnossosRoi(pT.raw.root, pT.raw.prefix, ...
    pT.local(1).bboxSmall, 'uint8', '', 'raw');
classification = readKnossosRoi(pT.local(1).class.root, pT.local(1).class.prefix, ...
    pT.local(1).bboxSmall, 'single', '', 'raw');

save([dataDirectory filesep 'segOptCortex' filesep 'aff' filesep 'cortex_region_1.mat'], 'raw', 'classification');
raw = readKnossosRoi(pT.raw.root, pT.raw.prefix, ...
    pT.local(2).bboxSmall, 'uint8', '', 'raw');
classification = readKnossosRoi(pT.local(2).class.root, pT.local(2).class.prefix, ...
    pT.local(2).bboxSmall, 'single', '', 'raw');
save([dataDirectory filesep 'segOptCortex' filesep 'aff' filesep 'cortex_region_2.mat'], 'raw', 'classification');

%% Example for looking at classification results
figure;
subplot(1,2,1);
imagesc(raw(:,:,1));
axis equal; axis off;
subplot(1,2,2);
imagesc(classification(:,:,1));
colormap('gray');
axis equal; axis off;

%% Segmentation of training regions
miniSegmentation(pT);

%% Classification of bounding box set in ../setParameterSettingsBig.m
bigFwdPass(p);

%% Segmentation of bounding box set in ../setParameterSettingsBig.m
miniSegmentation(p);
