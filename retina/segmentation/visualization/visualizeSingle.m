function visualizeSingle( param, map, algo, r, par1, par2 )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

display('Visualization Single:');
param.subfolder = [param.affMaps(map).name '_' num2str(algo) '_' num2str(param.r(r)) '_' num2str(param.pR{map,algo}{1}(par1), '%4.4f') '_' num2str(param.pR{map,algo}{2}(par2), '%4.4f') '/'];
tic;

a = load([param.dataFolder param.outputSubfolder param.affMaps(map).name '/evaluation' num2str(r) '-' num2str(algo) '.mat']);
b = load([param.dataFolder param.outputSubfolder param.affMaps(map).name '/seg' num2str(r) '-' num2str(algo) '.mat']);
load([param.dataFolder param.affSubfolder param.affMaps(map).name '.mat']);

if ~exist([param.dataFolder param.figureSubfolder param.subfolder], 'dir');
    mkdir([param.dataFolder param.figureSubfolder param.subfolder]);
end

% if param.makeSegMovies
%      makeSegMoviesP( param, b.v{par1,par2}, raw );
% end
% if param.makeErrorMovies
%      makeErrorMoviesP( param, a.v, b.v, raw, par1, par2);
% end
if param.plotObjSizeHist
%      visualizeObjHistP( param, a.v.general, b.v, par1, par2);
end
if param.plotObjChains
   visualizeObjectChainsP_mergerNew(param, a.v, b.v{par1,par2}, param.skel, par1, par2);
   visualizeObjectChainsP_show(param, a.v, b.v{par1,par2}, param.skel);
%      visualizeObjectChainsP_leftout(param, a.v, b.v{par1,par2}, param.skel, par1, par2);
end
% if param.makeErrorStacks
%      makeErrorStacksP( param, a.v, b.v, raw, par1, par2 );
% end
%toc


end

