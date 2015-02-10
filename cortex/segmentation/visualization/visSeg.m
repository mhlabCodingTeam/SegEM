%% Plot everything (including movies) for a specific segmentation
map = 4;
algo = 2;
r = 1;
par1 = 1;
par2 = 1;
visualizeSingle(param, map, algo, r, par1, par2);

%% KLEE: Show segmentation
map = 1;
algo = 1;
r = 1;
par1 = 3;
par2 = 2;
load([param.dataFolder param.affSubfolder param.affMaps(map).name '.mat'], 'raw');
load([param.dataFolder param.outputSubfolder param.affMaps(map).name '/seg' num2str(r) '-' num2str(algo) '.mat']);
addpath('KLEE');
KLEE_v4('stack', raw, 'stack_2', v{par1,par2});

%% KLEE: Show morhological opening:
map = 1;
r = 2;
load([param.dataFolder param.affSubfolder param.affMaps(map).name '.mat']);
load([param.dataFolder param.outputSubfolder param.affMaps(map).name '/MorphRecon' num2str(r) '.mat']);
addpath('/home/mberning/code/KLEE');
KLEE_v4('stack', aff, 'stack_2', v, 'stack_3', raw);

%% KLEE: Show errors of a segmentation (see makeErrorStacks.m)
map = 4;
algo = 2;
r = 1;
par1 = 1;
par2 = 1;
error = 1;
param.subfolder = [param.affMaps(map).name '_' num2str(algo) '_' num2str(param.r(r)) '_' num2str(param.pR{map,algo}{1}(par1), '%4.4f') '_' num2str(param.pR{map,algo}{2}(par2), '%4.4f') '/'];
load([param.dataFolder param.figureSubfolder param.subfolder 'errorStacks' num2str(error, '%2.2i') '.mat']);
addpath('/home/mberning/code/KLEE');
KLEE_v4('stack', raw, 'stack_2', obj, 'stack_3', skel);

a = skel == 2 & obj ~=0;
coord = ind2sub(size(a), find(a));

%% Remove KLEE path (as it shadows certain MATLAB functions used above when in path)
rmpath('/home/mberning/code/KLEE');