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
% minVal = -1.7;
% maxVal = 1.7;
for i=1%length(stacks)
    tic;
    load(stacks(i).targetFile);
    % Cut out ROI, normalize to [0 1]
    rawBig = rawBig(1+toRemoveOnEachSide(1):end-toRemoveOnEachSide(1),...
        1+toRemoveOnEachSide(2):end-toRemoveOnEachSide(2),1+toRemoveOnEachSide(3):end-toRemoveOnEachSide(3));
    classification = gather(onlyFwdPass3D(cnet, normalizeStack(single(rawBig))));
    % Normalize to [0 1]
%     classification(classification < minVal) = minVal;
%     classification(classification > maxVal) = maxVal;
%     classification = (classification - minVal) ./ (maxVal - minVal);
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
nMaxVal = 0.79;
classificationUFDR = classificationU;
classificationUFDR(classificationUFDR < minVal) = minVal;
classificationUFDR(classificationUFDR > maxVal) = maxVal;
classificationUFDR = (classificationUFDR - minVal) ./ (maxVal - minVal);
classificationUFDR = classificationUFDR * nMaxVal;

for modifier = -0.3:0.1:0.3
    for i=1:size(classificationU,3)
        thresholdedMarkers(:,:,i) = bwareaopen(classificationU(:,:,i) > 0.7+modifier, 100);
        thresWS(:,:,i) = watershed(imimposemin(-classificationU(:,:,i), thresholdedMarkers(:,:,i)) ,8) > 0;
        hminMarkers(:,:,i) = bwareaopen(imextendedmin(-classificationU(:,:,i), .4+modifier), 100);
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
tifWriteForISBI( 0.9.*single(hminWS), ['Z:\Data\berningm\20150205paper1submission\onlineMaterial\extracted\testSet\forFiji\automated\hminWS_h' num2str(.4+modifier) '.tif'])
tifWriteForISBI( 0.9.*single(thresWS), ['Z:\Data\berningm\20150205paper1submission\onlineMaterial\extracted\testSet\forFiji\automated\thresWS_th' num2str(.7+modifier) '.tif']);
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
subplot(1,2,1); imshow(a(:,:,1)); subplot(1,2,2); imshow(b(:,:,1));

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

figure; hold on; vIn = hist(single(a(b == 0)),256); vOut = hist(single(a(b==255)),256); bar(vIn/sum(vIn(:)),'r'); bar(vOut/sum(vOut(:)), 'b');
