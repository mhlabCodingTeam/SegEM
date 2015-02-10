function affBinned = binAff( aff, N_LEVELS )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
mini = min(aff(:));
maxi = max(aff(:));
affBinned = uint16(round((N_LEVELS-1) * (aff-mini)/(maxi-mini)));
end
