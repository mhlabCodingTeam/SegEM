function visualizeSingle( param, map, algo, r, par )

display('Visualization Single:');
tic;

% Load relevant data (aka. segmentation, classification, raw data & skeleton-based
% split-merger evaluation)
a = load([param.dataFolder param.outputSubfolder param.affMaps(map).name filesep 'evaluation' num2str(param.r(r)) '-' num2str(algo) '-' num2str(par) '.mat']);
b = load([param.dataFolder param.outputSubfolder param.affMaps(map).name filesep 'seg' num2str(param.r(r)) '-' num2str(algo) '-' num2str(par) '.mat']);
load([param.dataFolder param.affSubfolder param.affMaps(map).name '.mat']);

% Big contender for longest ever concatenation of strings to just get
% output subfolder (not sure what I thought back then, not important, must
% be unique so visualizeSingle can be used for multiple segmentations in
% parallel
outputFolder = [param.dataFolder param.figureSubfolder param.affMaps(map).name '-' num2str(param.r(r)) '-' num2str(algo)  '-' num2str(par, '%.3i') filesep];
if ~exist(outputFolder, 'dir');
    mkdir(outputFolder);
end

if param.makeSegMovies
     makeSegMovie( b.v, raw, [outputFolder 'segVideo.avi'] );
end

if param.makeErrorMovies
     makeErrorMoviesP( param, a.v, b.v, raw, par);
end

if param.plotObjSizeHist
	visualizeObjHistP( param, a.v.general, b.v, par);
end

if param.plotObjChains
	visualizeObjectChainsP_merger(param, a.v, b.v, param.skel, par);
	visualizeObjectChainsP_show(param, a.v, b.v, param.skel);
    visualizeObjectChainsP_leftout(param, a.v, b.v, param.skel, par);
end

toc

end

