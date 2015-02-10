%%
load('/media/big2/data/minicube/toKLEE.mat');
dbstop in watershedSeg_v2 at 18;
t = linspace(-3.5,-3.5,1);
v = linspace(400,400,1);
aff = affZ + affY + affX;

seg = watershedSeg_v2(aff, t, v);

%% Plot
x = 160:240;
y = 140:220;
z = 147;

load('/media/big2/data/minicube/toKLEE.mat');
figure('position', [ 1605 787 1776 311]);
subplot(1,5,1);
imagesc(raw(x,y,z));
colormap('gray');
axis off;
subplot(1,5,2);
imagesc(aff(x,y,z));
colormap('gray');
axis off;
subplot(1,5,3);
imagesc(fgm1(x,y,z));
colormap('gray');
axis off;
subplot(1,5,4);
imagesc(fgm2(x,y,z));
colormap('gray');
axis off;
subplot(1,5,5);
imagesc(segmentation{1,1}(x,y,z));
colormap('gray');
axis off;

%%
load('/media/big2/data/minicube/toKLEE.mat');
dbstop in watershedSeg at 36;
r = linspace(1,1,1);
h = linspace(0.2,0.2,1);
v = linspace(100,100,1);
aff = affZ;

seg = watershedSeg(aff, r, h, v);

%% Plot
x = 160:240;
y = 140:220;
z = 147;

load('/media/big2/data/minicube/toKLEE.mat');
figure('position', [ 1605 787 1776 311]);
subplot(1,6,1);
imagesc(raw(x,y,z));
colormap('gray');
axis off;
subplot(1,6,2);
imagesc(affReconRecon(x,y,z));
colormap('gray');
axis off;
subplot(1,6,3);
imagesc(affHmin(x,y,z));
colormap('gray');
axis off;
subplot(1,6,4);
imagesc(bw1(x,y,z));
colormap('gray');
axis off;
subplot(1,6,5);
imagesc(bw2(x,y,z));
colormap('gray');
axis off;
subplot(1,6,6);
imagesc(segmentation{1,1}(x,y,z));
colormap('gray');
axis off;

%%
load('/media/big2/data/minicube/toKLEE.mat');
dbstop in watershedSeg at 36;
r = linspace(1,1,1);
h = linspace(0.2,0.2,1);
v = linspace(100,100,1);
aff = affZ;

seg = watershedSeg(aff, r, h, v);

%% Plot
x = 160:240;
y = 140:220;
z = 147;

load('/media/big2/data/minicube/toKLEE.mat');
figure('position', [ 1605 787 1776 311]);
subplot(1,6,1);
imagesc(raw(x,y,z));
colormap('gray');
axis off;
subplot(1,6,2);
imagesc(affReconRecon(x,y,z));
colormap('gray');
axis off;
subplot(1,6,3);
imagesc(affHmin(x,y,z));
colormap('gray');
axis off;
subplot(1,6,4);
imagesc(bw1(x,y,z));
colormap('gray');
axis off;
subplot(1,6,5);
imagesc(bw2(x,y,z));
colormap('gray');
axis off;
subplot(1,6,6);
imagesc(segmentation{1,1}(x,y,z));
colormap('gray');
axis off;
%%
load('/media/big2/data/minicube/toKLEE.mat');
dbstop in watershedSeg at 36;
t = linspace(-3.5,-3.5,1);
v = linspace(100,100,1);
aff = affZ + affY + affX;

seg = watershedSeg_v3(aff, t, v);

%% Plot
x = 160:240;
y = 140:220;
z = 147;

load('/media/big2/data/minicube/toKLEE.mat');
figure('position', [ 1605 787 1776 311]);
subplot(1,6,1);
imagesc(raw(x,y,z));
colormap('gray');
axis off;
subplot(1,6,2);
imagesc(affReconRecon(x,y,z));
colormap('gray');
axis off;
subplot(1,6,3);
imagesc(affHmin(x,y,z));
colormap('gray');
axis off;
subplot(1,6,4);
imagesc(bw1(x,y,z));
colormap('gray');
axis off;
subplot(1,6,5);
imagesc(bw2(x,y,z));
colormap('gray');
axis off;
subplot(1,6,6);
imagesc(segmentation{1,1}(x,y,z));
colormap('gray');
axis off;

