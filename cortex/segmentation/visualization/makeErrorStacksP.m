function makeErrorStacksP( param, eval, segmentation, raw, par1, par2)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% colors = {'or' 'og' 'ob' 'oy' 'oc' 'om'};

for errorIdx=1:length(eval.merge(par1,par2).obj)
    temp =  single(segmentation{par1,par2});
    temp(temp == eval.merge(par1,par2).idx(errorIdx)) = -1;
    temp(temp ~= -1) = 0;
    temp(temp == -1) = 255;
    obj = uint8(temp);
    skel = zeros(size(raw));
    for m=1:length(eval.merge(par1,par2).obj{errorIdx})
        idNodes = eval.nodes{eval.merge(par1,par2).obj{errorIdx}(m)};
        skel(sub2ind(size(skel), idNodes(:,1), idNodes(:,2), idNodes(:,3))) = m;
    end
    save([param.dataFolder param.figureSubfolder param.subfolder '/errorStacks' num2str(errorIdx, '%2.2i') '.mat'], 'raw', 'obj', 'skel');
    display(num2str(errorIdx));
end

end

