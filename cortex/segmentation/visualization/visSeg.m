%% Plot everything (including movies) for a specific segmentation

%% Plot for which ROI index, see: param.affMaps(index)
map = 1;
param.affMaps(map)
% which algorothm to use, see param.algo
algo = 1;
param.algo(algo).fun
% which radius to use, index to param.r(r)
r = 1;
param.r(r)

%% 
paramCell = getParamCombinations(param.algo);
par = 10;
paramCell{algo}{par}{2};

%%
visualizeSingle(param, map, algo, r, par);
