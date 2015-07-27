%% Set up SegEM path etc
cd('C:\Users\berningm\code\SegEM\');
% Set Data Directory to Z:\Data\berningm\20150205paper1submission
% Output Directory chosen freely
run('C:\Users\berningm\code\SegEM\initalSettings.m')

%% First convert test set from KLEE 2D contours to 3D label matrix as used
% in the SegEM package

testSet.cutoffDistance = 4;
testSet.rawDir = [dataDirectory 'datasets\2012-09-28_ex145_07x2_corrected\color\1\'];
testSet.rawPrefix = '2012-09-28_ex145_07x2_corrected_mag1';
testSet.sourceDir = [dataDirectory 'onlineMaterial\extracted\testSet\KLEE_tracings\'];
testSet.stackDir = [dataDirectory 'onlineMaterial\extracted\testSet\stackKLEE\'];
testSet.targetDir = [dataDirectory 'onlineMaterial\extracted\testSet\targetKLEE\'];
testSet.metaFile = [dataDirectory 'onlineMaterial\extracted\testSet\parameter.mat'];
testSet.border = [50; 50; 25];

% Note MB: Checked that all settings are equal to training set supplied
% with SegEM
if ~exist(testSet.metaFile, 'file')
    convertTestSetFromKLEETracingToLabelmatrix(testSet);
end
load(testSet.metaFile);

%% Use ImageJ for calculating metrics 
% See http://fiji.sc/Miji
addpath 'C:\Users\berningm\Downloads\fiji-win64-20140602\Fiji.app\scripts\';
Miji

%% Calculate classification and segmentation for regions in test set

% Load old cortex CNN
load([dataDirectory filesep 'supplement' filesep 'extracted' filesep 'cortex - CNN20130516T204040_8_3.mat'], 'cnet');
% Run on Matlab GPU, was jacket GPU before
cnet.run.actvtClass = @gpuArray;

% Calculate how much of larger FOV to trim away
toRemove = 2*settings.border' - cnet.randOfConvn; 
toRemoveOnEachSide = toRemove./2;
% Constants for normalization
minVal = -1.7;
maxVal = 1.7;
for i=2%length(stacks)
    tic;
    load(stacks(i).targetFile);
    % Cut out ROI, normalize to [0 1]
    rawBig = rawBig(1+toRemoveOnEachSide(1):end-toRemoveOnEachSide(1),...
        1+toRemoveOnEachSide(2):end-toRemoveOnEachSide(2),1+toRemoveOnEachSide(3):end-toRemoveOnEachSide(3));
    classification = gather(onlyFwdPass3D(cnet, normalizeStack(single(rawBig))));
    % Normalize to [0 1]
    classification(classification < minVal) = minVal;
    classification(classification > maxVal) = maxVal;
    classification = (classification - minVal) ./ (maxVal - minVal);
    target = single(target);
%     tifWriteForISBI(single(target), [dataDirectory 'onlineMaterial\extracted\testSet\forFiji\' num2str(stacks(i).taskID, '%.3i') 'original' '.tif']);
%     tifWriteForISBI(classification, [dataDirectory 'onlineMaterial\extracted\testSet\forFiji\' num2str(stacks(i).taskID, '%.3i') 'proposal' '.tif']);
    toc;
end

%% Interpolate (upsample) results to 512^2 in plane slices
[X,Y,Z] = meshgrid(1:100,1:100,1:100);
[Xq,Yq,Zq] = meshgrid(linspace(1,100,512),linspace(1,100,512),1:100);
targetU = interp3(X,Y,Z,single(target > 0),Xq,Yq,Zq);
classificationU = interp3(X,Y,Z,classification,Xq,Yq,Zq);
rawBefore = single(rawBig(26:125,26:125,11:110));
rawBefore = (rawBefore - min(rawBefore(:))) ./ (max(rawBefore(:)) - min(rawBefore(:)));
rawBigU = interp3(X,Y,Z,rawBefore,Xq,Yq,Zq);

%% 
classificationUFDR = classificationU;
minVal2 = 0.4;
maxVal2 = 0.9;
classificationUFDR(classificationUFDR < minVal2) = minVal2;
classificationUFDR(classificationUFDR > maxVal2) = maxVal2;
classificationUFDR = (classificationUFDR - minVal2) ./ (maxVal2 - minVal2);
MIJ.createImage('classification', classificationUFDR, 1);

%% ISBI challenge constructed result!! Game the system!

% Structure element for erosion
r = 10;
[x,y] = meshgrid(-r:r,-r:r);
se = (x/r).^2 + (y/r).^2 <= 1;

% Upsample target
targetU = interp3(X,Y,Z,single(target > 0),Xq,Yq,Zq);
% Classification
classificationU = interp3(X,Y,Z,classification,Xq,Yq,Zq);

% Focused dynamic range (map intervall [minVal maxVal] to [0 nMaxVal] and map outliers to borders 
minVal = -0.5; maxVal = 0.5;
nDR = 0.79;
classificationUFDR = classificationU;
classificationUFDR(classificationUFDR < minVal) = minVal;
classificationUFDR(classificationUFDR > maxVal) = maxVal;
classificationUFDR = (classificationUFDR - minVal) ./ (maxVal - minVal);
classificationUFDR = classificationUFDR * nDR;

for modifier = -0.15:0.01:0.15
    for i=1:size(classificationU,3)
        thresholdedMarkers(:,:,i) = bwareaopen(classificationU(:,:,i) > 0.5+modifier, 100);
        thresWS(:,:,i) = watershed(imimposemin(-classificationU(:,:,i), thresholdedMarkers(:,:,i)) ,8) > 0;
        hminMarkers(:,:,i) = bwareaopen(imextendedmin(-classificationU(:,:,i), .6+modifier), 100);
        hminWS(:,:,i) = watershed(imimposemin(-classificationU(:,:,i), hminMarkers(:,:,i)) ,8) > 0;
%         subplot(2,3,1);
%         imshow(rawBigU(:,:,i));
%         subplot(2,3,2)
%         imshow(classificationU(:,:,i));
%         subplot(2,3,3)
%         imshow(targetU(:,:,i));
%         subplot(2,4,5)
%         imshow(thresholdedMarkers(:,:,i));
%         subplot(2,4,6)
%         imshow(thresWS(:,:,i)*255);
%         subplot(2,4,7)
%         imshow(hminMarkers(:,:,i));
%         subplot(2,4,8)
%         imshow(hminWS(:,:,i)*255);
%         pause(2);
    end
tifWriteForISBI( 0.9.*single(hminWS), ['Z:\Data\berningm\20150205paper1submission\onlineMaterial\extracted\testSet\forFiji\automated\hmin\WS_h' num2str(.4+modifier, '%.2f') '.tif'])
tifWriteForISBI( 0.9.*single(thresWS), ['Z:\Data\berningm\20150205paper1submission\onlineMaterial\extracted\testSet\forFiji\automated\thres\WS_th' num2str(.7+modifier, '%.2f') '.tif']);
end

%% Save files

%% Put it together
toSubmit = classificationUFDR + 0.105;
toSubmit(~hminWS) = 0;
tifWriteForISBI( toSubmit, 'Z:\Data\berningm\20150205paper1submission\onlineMaterial\extracted\testSet\forFiji\finalI4Up.tif');
tifWriteForISBI( targetU, 'Z:\Data\berningm\20150205paper1submission\onlineMaterial\extracted\testSet\forFiji\targetI4Up.tif');

%% old
for i=1:size(classificationUFDR)
    affHmin = imhmin(imcomplement(classificationUS(:,:,i)), .85, 4);
    bw1 = imregionalmin(affHmin, 4);
    bw1 = bwareaopen(bw1, 10, 4);
    affImposed = imimposemin(imcomplement(classificationUS(:,:,i)), bw1);
    afterWS = watershed(affImposed, 4) > 0;
    segmentationU(:,:,i) = imerode(afterWS, se);
    segmentationUAE(:,:,i) = bwareaopen(segmentationU(:,:,i),10000);
    segmentationUAEER(:,:,i) = imerode(segmentationUAE(:,:,i),se);
    subplot(2,3,1);
    imshow(classificationUS(:,:,i));
    subplot(2,3,2)
    imshow(targetU(:,:,i));
    subplot(2,3,3)
    imshow(bw1);
    subplot(2,3,4)
    imshow(segmentationU(:,:,i)*255);
    subplot(2,3,5)
    imshow(segmentationUAE(:,:,i)*255);
    subplot(2,3,6)
    imshow(segmentationUAEER(:,:,i)*255);
    pause(2);
end

%%
MIJ.createImage('classification', classificationU, 1);
MIJ.createImage('target', targetU, 1);

%%
MIJ.createImage('classification', rawBigU, 1);
MIJ.createImage('target', targetU, 1);

%%
%save('C:\Users\berningm\Desktop\temp.mat');
MIJ.createImage('classification', classification, 1);
MIJ.createImage('target', single(target > 0), 1);

%% Use MIJ for calculation of Errors as indicated in ISBI challenge
MIJ.createImage('classification', classification, 1);
MIJ.createImage('target', single(target > 0), 1);
% For threshold comparison
MIJ.createImage('classification', single(rawBig(26:125,26:125,11:110)), 1);
MIJ.createImage('target', single(target > 0), 1);
% Recorded macro and copied commands to here
MIJ.run('')
MIJ.WindowManager.getImage('classification')

%% Look at ISBI challenge data

for i=1:30; a(:,:,i) = imread('C:\Users\berningm\Desktop\ISBI challenge\train-volume.tif', 'Index', i); end
for i=1:30; b(:,:,i) = rot90(imread('C:\Users\berningm\Desktop\ISBI challenge\train-labels.tif', 'Index', i)); end
x = 1000; y = 1000; z = 1000;
raw = readKnossosRoi('Z:\Data\berningm\20150205paper1submission\datasets\2012-09-28_ex145_07x2_corrected\color\1\', '2012-09-28_ex145_07x2_corrected_mag1', [x x+182; y y+182; z z+54]);

figure;
subplot(2,2,1);
imagesc(a(:,:,15));
daspect([50 50 4]);
title('x-y reslice');
axis off;
subplot(2,2,2);
imagesc(squeeze(a(:,256,:)));
daspect([4 50 50]);
title('x-z reslice');
axis off;
subplot(2,2,3)
imagesc(squeeze(a(256,:,:)));
daspect([4 50 50]);
title('y-z reslice');
axis off;
colormap('gray');

figure;
subplot(2,2,1);
imagesc(raw(:,:,27));
daspect([28 28 11.24]);
title('x-y reslice');
axis off;
subplot(2,2,2);
imagesc(squeeze(raw(:,91,:)));
daspect([11.24 28 28]);
title('x-z reslice');
axis off;
subplot(2,2,3)
imagesc(squeeze(raw(91,:,:)));
daspect([11.24 28 28]);
title('y-z reslice');
axis off;
colormap('gray');


figure; hold on; vIn = hist(single(a(b == 0)),256); vOut = hist(single(a(b==255)),256); bar(vIn/sum(vIn(:)),'r'); bar(vOut/sum(vOut(:)), 'b');

%% 11.06.2015 Automate generation of tiff-stacks for Fiji (this is optimization on training)
% THis was never used, see cell with different modifier above, bad
% bookkeppoing
% Load old cortex CNN
load([dataDirectory filesep 'supplement' filesep 'extracted' filesep 'cortex - CNN20130516T204040_8_3.mat'], 'cnet');
% Run on Matlab GPU, was jacket GPU before
cnet.run.actvtClass = @gpuArray;

% Calculate how much of larger FOV of raw data to trim away
toRemove = 2*settings.border' - cnet.randOfConvn;
toRemoveOnEachSide = toRemove./2;

% Grids for upsampling
[X,Y,Z] = meshgrid(1:100,1:100,1:100);
[Xq,Yq,Zq] = meshgrid(linspace(1,100,512),linspace(1,100,512),1:100);

for i=1:length(stacks)
    tic;
    load(stacks(i).targetFile);
    % Cut out ROI, normalize to [0 1]
    rawBig = rawBig(1+toRemoveOnEachSide(1):end-toRemoveOnEachSide(1),...
        1+toRemoveOnEachSide(2):end-toRemoveOnEachSide(2),1+toRemoveOnEachSide(3):end-toRemoveOnEachSide(3));
    classification = gather(onlyFwdPass3D(cnet, normalizeStack(single(rawBig))));
    target = single(target);
    % Upsample target
    targetU = interp3(X,Y,Z,single(target > 0),Xq,Yq,Zq);
    % Upsample classification
    classificationU = interp3(X,Y,Z,classification,Xq,Yq,Zq);
    
    % Focused dynamic range (map intervall [minVal maxVal] to [0 nMaxVal] and map outliers to borders
    minVal = -0.5; maxVal = 0.5;
    nDR = 0.79;
    % One could think about whether e.g. sigmoid here is better
    classificationUFDR = classificationU;
    classificationUFDR(classificationUFDR < minVal) = minVal;
    classificationUFDR(classificationUFDR > maxVal) = maxVal;
    classificationUFDR = (classificationUFDR - minVal) ./ (maxVal - minVal);
    classificationUFDR = classificationUFDR * nDR;
    
    for modifier = -0.3:0.1:0.3
        for z=1:size(classificationU,3)
            thresholdedMarkers(:,:,z) = bwareaopen(classificationU(:,:,z) > 0.7+modifier, 100);
            thresWS(:,:,z) = watershed(imimposemin(-classificationU(:,:,z), thresholdedMarkers(:,:,i)) ,8) > 0;
            hminMarkers(:,:,z) = bwareaopen(imextendedmin(-classificationU(:,:,z), .4+modifier), 100);
            hminWS(:,:,z) = watershed(imimposemin(-classificationU(:,:,z), hminMarkers(:,:,z)) ,8) > 0;
        end
        tifWriteForISBI( 0.9.*single(hminWS), ['Z:\Data\berningm\20150205paper1submission\onlineMaterial\extracted\testSet\forFiji\automated\hmin\WS_h' num2str(.4+modifier) '.tif'])
        tifWriteForISBI( 0.9.*single(thresWS), ['Z:\Data\berningm\20150205paper1submission\onlineMaterial\extracted\testSet\forFiji\automated\thres\WS_th' num2str(.7+modifier) '.tif']);
    end
    toSubmit = classificationUFDR + 0.105;
    toSubmit(~hminWS) = 0;
    tifWriteForISBI( toSubmit, 'Z:\Data\berningm\20150205paper1submission\onlineMaterial\extracted\testSet\forFiji\finalI4Up.tif');
    tifWriteForISBI( targetU, 'Z:\Data\berningm\20150205paper1submission\onlineMaterial\extracted\testSet\forFiji\targetI4Up.tif');

end

%% 14.06.2015 Automate generation of tiff-stacks for Fiji of all test regions

% Load old cortex CNN
load([dataDirectory filesep 'supplement' filesep 'extracted' filesep 'cortex - CNN20130516T204040_8_3.mat'], 'cnet');
% Run on Matlab GPU, was jacket GPU before
cnet.run.actvtClass = @gpuArray;

% Calculate how much of larger FOV of raw data to trim away
toRemove = 2*settings.border' - cnet.randOfConvn;
toRemoveOnEachSide = toRemove./2;

% Grids for upsampling
[X,Y,Z] = meshgrid(1:100,1:100,1:100);
[Xq,Yq,Zq] = meshgrid(linspace(1,100,512),linspace(1,100,512),1:100);

for i=15:length(stacks)
    display(num2str(i));
    tic;
    load(stacks(i).targetFile);
    % Cut out ROI, normalize to [0 1]
    rawBig = rawBig(1+toRemoveOnEachSide(1):end-toRemoveOnEachSide(1),...
        1+toRemoveOnEachSide(2):end-toRemoveOnEachSide(2),1+toRemoveOnEachSide(3):end-toRemoveOnEachSide(3));
    classification = gather(onlyFwdPass3D(cnet, normalizeStack(single(rawBig))));
    target = single(target);
    % Upsample target
    targetU = interp3(X,Y,Z,single(target > 0),Xq,Yq,Zq, 'nearest');
    % Upsample classification
    classificationU = interp3(X,Y,Z,classification,Xq,Yq,Zq);
    
    % Focused dynamic range (map intervall [minVal maxVal] to [nMinVal nDR] and map outliers to borders
    minVal = 0; maxVal = 1;
    nDR = 0.89; nMinVal = 0.105;
    % One could think about whether e.g. sigmoid here is better
    classificationUFDR = classificationU;
    classificationUFDR(classificationUFDR < minVal) = minVal;
    classificationUFDR(classificationUFDR > maxVal) = maxVal;
    classificationUFDR = (classificationUFDR - minVal) ./ (maxVal - minVal);
    classificationUFDR = classificationUFDR * nDR + nMinVal;

    % Use segmentation to generate borders
    for z=1:size(classificationU,3)
        hminMarkers(:,:,z) = bwareaopen(imextendedmin(-classificationU(:,:,z), .7), 100);
        hminWS(:,:,z) = watershed(imimposemin(-classificationU(:,:,z), hminMarkers(:,:,z)) ,8) > 0;
    end
    toSubmit=classificationUFDR;
%     tifWriteForISBI( toSubmit, ['Z:\Data\berningm\20150205paper1submission\onlineMaterial\extracted\testSet\forFiji\automated\testSetISBImetrics\20150622\c' num2str(i, '%.2i') '.tif']);
    toSubmit(~hminWS) = 0;
%     tifWriteForISBI( toSubmit, ['Z:\Data\berningm\20150205paper1submission\onlineMaterial\extracted\testSet\forFiji\automated\testSetISBImetrics\20150622\w' num2str(i, '%.2i') '.tif']);
%     tifWriteForISBI( targetU,  ['Z:\Data\berningm\20150205paper1submission\onlineMaterial\extracted\testSet\forFiji\automated\testSetISBImetrics\20150622\t' num2str(i, '%.2i') '.tif']);
    toc;
end

%% Weird shiat for review

    % Focused dynamic range (map intervall [minVal maxVal] to [nMinVal nDR] and map outliers to borders
    minVal = -1; maxVal = 0;
    nDR = 1; nMinVal = 0;
    % One could think about whether e.g. sigmoid here is better
    classificationUFDR = classificationU;
    classificationUFDR(classificationUFDR < minVal) = minVal;
    classificationUFDR(classificationUFDR > maxVal) = maxVal;
    classificationUFDR = (classificationUFDR - minVal) ./ (maxVal - minVal);
    classificationUFDR = classificationUFDR * nDR + nMinVal;

    % Use segmentation to generate borders
    for z=1:size(classificationU,3)
        hminMarkers(:,:,z) = bwareaopen(imextendedmin(-classificationU(:,:,z), .7), 100);
        hminWS(:,:,z) = watershed(imimposemin(-classificationU(:,:,z), hminMarkers(:,:,z)) ,8) > 0;
    end
    toSubmit=classificationUFDR;
    toSubmit(~hminWS) = 0;
    tifWriteForISBI( toSubmit, ['Z:\Data\berningm\20150205paper1submission\onlineMaterial\extracted\testSet\forFiji\automated\testSetISBImetrics\new\c' num2str(i, '%.2i') '.tif']);

    %% Weird shiat for review (on original resolution this time)

    clear hminWS hminMarkers;
    % Focused dynamic range (map intervall [minVal maxVal] to [nMinVal nDR] and map outliers to borders
    minVal = -1; maxVal = 0;
    nDR = 1; nMinVal = 0;
    % One could think about whether e.g. sigmoid here is better
    classificationUFDR = classification;
    classificationUFDR(classificationUFDR < minVal) = minVal;
    classificationUFDR(classificationUFDR > maxVal) = maxVal;
    classificationUFDR = (classificationUFDR - minVal) ./ (maxVal - minVal);
    classificationUFDR = classificationUFDR * nDR + nMinVal;

    % Use segmentation to generate borders
    for z=1:size(classification,3)
        hminMarkers(:,:,z) = bwareaopen(imextendedmin(-classification(:,:,z), .7), 100);
        hminWS(:,:,z) = watershed(imimposemin(-classification(:,:,z), hminMarkers(:,:,z)) ,8) > 0;
    end
    toSubmit = classificationUFDR;
    toSubmit(~hminWS) = 0;
    tifWriteForISBI( toSubmit, ['Z:\Data\berningm\20150205paper1submission\onlineMaterial\extracted\testSet\forFiji\automated\testSetISBImetrics\new\cSmall' num2str(i, '%.2i') '.tif']);
    tifWriteForISBI( single(target > 0.5), ['Z:\Data\berningm\20150205paper1submission\onlineMaterial\extracted\testSet\forFiji\automated\testSetISBImetrics\new\tSmall' num2str(i, '%.2i') '.tif']);
    
       %% Weird shiat for review (on original resolution this time)
       
    [X,Y,Z] = meshgrid(1:100,1:100,1:100);
    [Xq,Yq,Zq] = meshgrid(linspace(1,100,round(100/4*11)),linspace(1,100,round(100/4*11)),1:100);
    targetU = interp3(X,Y,Z,single(target > 0),Xq,Yq,Zq, 'nearest');
    % Upsample classification
    classificationU = interp3(X,Y,Z,classification,Xq,Yq,Zq);
    clear hminWS hminMarkers;
    % Focused dynamic range (map intervall [minVal maxVal] to [nMinVal nDR] and map outliers to borders
    minVal = -1; maxVal = 0;
    nDR = 1; nMinVal = 0;
    % One could think about whether e.g. sigmoid here is better
    classificationUFDR = classificationU;
    classificationUFDR(classificationUFDR < minVal) = minVal;
    classificationUFDR(classificationUFDR > maxVal) = maxVal;
    classificationUFDR = (classificationUFDR - minVal) ./ (maxVal - minVal);
    classificationUFDR = classificationUFDR * nDR + nMinVal;

    % Use segmentation to generate borders
    for z=1:size(classificationU,3)
        hminMarkers(:,:,z) = bwareaopen(imextendedmin(-classificationU(:,:,z), .7), 100);
        hminWS(:,:,z) = watershed(imimposemin(-classificationU(:,:,z), hminMarkers(:,:,z)) ,8) > 0;
    end
    toSubmit = classificationUFDR;
    toSubmit(~hminWS) = 0;
    tifWriteForISBI( toSubmit, ['Z:\Data\berningm\20150205paper1submission\onlineMaterial\extracted\testSet\forFiji\automated\testSetISBImetrics\new\cSameVoxelSize' num2str(i, '%.2i') '.tif']);
    tifWriteForISBI( single(targetU > 0.5), ['Z:\Data\berningm\20150205paper1submission\onlineMaterial\extracted\testSet\forFiji\automated\testSetISBImetrics\new\tSameVoxelSize' num2str(i, '%.2i') '.tif']);
     
%% MORE SHIAT: variation of information on 2-D planes (later 3D)

%% Update 24.06.2015 for visualization of 2 "best" SegEM stacks
i = 15; % Corresponds to c/t/w numbering in files or Test i-1 in Excel as first is trianing region

% Load old cortex CNN
load([dataDirectory filesep 'supplement' filesep 'extracted' filesep 'cortex - CNN20130516T204040_8_3.mat'], 'cnet');
% Run on Matlab GPU, was jacket GPU before
cnet.run.actvtClass = @gpuArray;

% Calculate how much of larger FOV of raw data to trim away
toRemove = 2*settings.border' - cnet.randOfConvn;
toRemoveOnEachSide = toRemove./2;

% Grids for upsampling
[X,Y,Z] = meshgrid(1:100,1:100,1:100);
[Xq,Yq,Zq] = meshgrid(linspace(1,100,512),linspace(1,100,512),1:100);

display(num2str(i));
tic;
load(stacks(i).targetFile);
% Cut out ROI, normalize to [0 1]
rawBig = rawBig(1+toRemoveOnEachSide(1):end-toRemoveOnEachSide(1),...
    1+toRemoveOnEachSide(2):end-toRemoveOnEachSide(2),1+toRemoveOnEachSide(3):end-toRemoveOnEachSide(3));
classification = gather(onlyFwdPass3D(cnet, normalizeStack(single(rawBig))));
target = single(target);
% Upsample target
targetU = interp3(X,Y,Z,single(target > 0),Xq,Yq,Zq, 'nearest');
% Upsample classification
classificationU = interp3(X,Y,Z,classification,Xq,Yq,Zq);
rawU = interp3(X,Y,Z, single(rawBig(26:end-25,26:end-25,11:end-10)), Xq, Yq, Zq);

% Focused dynamic range (map intervall [minVal maxVal] to [nMinVal nDR] and map outliers to borders
minVal = 0; maxVal = 1;
nDR = 0.89; nMinVal = 0.105;
% One could think about whether e.g. sigmoid here is better
classificationUFDR = classificationU;
classificationUFDR(classificationUFDR < minVal) = minVal;
classificationUFDR(classificationUFDR > maxVal) = maxVal;
classificationUFDR = (classificationUFDR - minVal) ./ (maxVal - minVal);
classificationUFDR = classificationUFDR * nDR + nMinVal;

% Use segmentation to generate borders
for z=1:size(classificationU,3)
    hminMarkers(:,:,z) = bwareaopen(imextendedmin(-classificationU(:,:,z), .7), 100);
    hminWS(:,:,z) = watershed(imimposemin(-classificationU(:,:,z), hminMarkers(:,:,z)) ,8) > 0;
end
toSubmit=classificationUFDR;
toSubmit(~hminWS) = 0;
toc;

makeMovie(rawU, ['C:\Users\berningm\Desktop\ISBI challenge\' num2str(i) 'raw.avi']);
makeMovie(toSubmit, ['C:\Users\berningm\Desktop\ISBI challenge\' num2str(i) 'submitted.avi']);
makeMovie(toSubmit > 0, ['C:\Users\berningm\Desktop\ISBI challenge\' num2str(i) 'thresholded.avi']);
makeMovie(targetU > 0, ['C:\Users\berningm\Desktop\ISBI challenge\' num2str(i) 'target.avi']);


maxVal = max(rawU(:));
minVal = min(rawU(:));
rawU = rawU - minVal;
rawU = rawU ./ (maxVal - minVal);

makeMovie(cat(2, rawU, toSubmit, toSubmit > 0, targetU), ['C:\Users\berningm\Desktop\ISBI challenge\' num2str(i) 'combined.avi']);

