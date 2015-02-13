function seg = watershed_3D( affX, affY, affZ, bw)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
mex = true; % an binAff + 1 denken
N_LEVELS = 20000;
N_LEVELS_BOUNDARY = 1;

affX = binAff(affX, N_LEVELS);
affY = binAff(affY, N_LEVELS);
affZ = binAff(affZ, N_LEVELS);
marker = uint16(labelmatrix(bwconncomp(bw)));
if mex
    if sum(marker(:) ~= 0) == 0
        seg = zeros(384,384,384);
    else
        seg = watershed_threeTimes3D(affX, affY, affZ, marker, N_LEVELS, N_LEVELS - N_LEVELS_BOUNDARY);
    end 
else
    seg = sk_mbwshed_3d_2(affX, affY, affZ, marker, N_LEVELS);
end

end




