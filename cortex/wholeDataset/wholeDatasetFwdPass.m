%% Classification of training regions
minicubeFwdPass(pT);

%% Wait for job to finish 
jm = parcluster('local');
% Look at jobmanager
jm
% Look at jobs on specific jobmanager
jm(1).Jobs
% Look at tasks in specific job on specific jobmanager
jm(1).Jobs(1).Tasks
% If one wants to automate waiting, simply do (waits until Jobs(1) on jm(1) changes state to finished):
wait(jm(1).Jobs(1), 'finished')

%%
% Create directory for segmentation parameter search input (CNN
% classification results)
if ~exist([outputDirectory filesep 'segOptCortex' filesep 'aff' filesep], 'dir')
    mkdir([outputDirectory filesep 'segOptCortex' filesep 'aff' filesep]);
end

% Save for mainSegCortex (raw and classification data both, dense annotation region 1):
raw = readKnossosRoi(pT.raw.root, pT.raw.prefix, ...
    pT.local(1).bboxSmall, 'uint8', '', 'raw');
classification = readKnossosRoi(pT.local(1).class.root, pT.local(1).class.prefix, ...
    pT.local(1).bboxSmall, 'single', '', 'raw');
save([outputDirectory filesep 'segOptCortex' filesep 'aff' filesep 'cortex_region_1.mat'], 'raw', 'classification');

% Save for mainSegCortex (raw and classification data both, dense annotation region 2):
raw = readKnossosRoi(pT.raw.root, pT.raw.prefix, ...
    pT.local(2).bboxSmall, 'uint8', '', 'raw');
classification = readKnossosRoi(pT.local(2).class.root, pT.local(2).class.prefix, ...
    pT.local(2).bboxSmall, 'single', '', 'raw');
save([outputDirectory filesep 'segOptCortex' filesep 'aff' filesep 'cortex_region_2.mat'], 'raw', 'classification');

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

%% Another example: Apply cortex classifier to Philip Laserstein's stack

% Load old cortex CNN
load([dataDirectory filesep 'supplement' filesep 'extracted' filesep 'cortex - CNN20130516T204040_8_3.mat'], 'cnet');
% Run on Matlan GPU, was jacket GPU before
cnet.run.actvtClass = @single;
% Where raw data is located (no need to change to dataDirectory, will not
% be included in submission)
stP.raw.root = 'Z:\Data\berningm\stackPL\color\1\';
stP.raw.prefix = '2015-02-05_st118_st118a_mag1';
% Which region to classify
bbox = [1501 1800; 1501 1800; 15 314];
% Load data with right border for cnet
bboxWithBorder(:,1) = bbox(:,1) - ceil(cnet.randOfConvn'/2);
bboxWithBorder(:,2) = bbox(:,2) + ceil(cnet.randOfConvn'/2);
raw = readKnossosRoi(stP.raw.root, stP.raw.prefix, bboxWithBorder);

%% Make sure raw data is actually read
implay(raw);

%% Normalize data
if cnet.normalize
	raw = single(raw) - 155;
    raw = raw ./ 57;
else
	raw = single(raw);
end

%% Apply CNN
classification = onlyFwdPass3D(cnet, raw);

%% Look at result
implay(classification)

%% display images
z = 100;
figure;
subplot(1,2,1);
% Weird indexing necessary due to border of CNN classification
imagesc(raw(1+cnet.randOfConvn(1)/2:end-cnet.randOfConvn(1)/2,...
    1+cnet.randOfConvn(1)/2:end-cnet.randOfConvn(1)/2,...
    z+cnet.randOfConvn(3)/2));
axis equal; axis off;
subplot(1,2,2);
imagesc(classification(:,:,z));
axis equal; axis off;
colormap('gray');

%% segment (no grid serach performed du to no dense annotation, just tried some values)
% probably step someone could optimize easiest
segmentation = watershedSeg_v1_cortex( imcomplement(classification), {.35 50} );

%% display images
z = 100;
figure;
subplot(1,2,1);
% Weird indexing necessary due to border of CNN classification
imagesc(raw(1+cnet.randOfConvn(1)/2:end-cnet.randOfConvn(1)/2,...
    1+cnet.randOfConvn(1)/2:end-cnet.randOfConvn(1)/2,...
    z+cnet.randOfConvn(3)/2));
axis equal; axis off;
subplot(1,2,2);
imagesc(segmentation(:,:,z));
axis equal; axis off;
colormap('gray');

%% Make video
raw = readKnossosRoi(stP.raw.root, stP.raw.prefix, bboxWithBorder);
makeSegMovie(segmentation,raw(1+cnet.randOfConvn(1)/2:end-cnet.randOfConvn(1)/2,...
    1+cnet.randOfConvn(1)/2:end-cnet.randOfConvn(1)/2,...
    1+cnet.randOfConvn(3)/2:end-cnet.randOfConvn(3)/2),[outputDirectory filesep 'PL_segmentation.avi']);
