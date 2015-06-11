function [KLEE_savedTracing, bbox] = findBBoxKLEE( KLEE_savedTracing )
% Extracts bbox from struct & checks for z-position inconsitency between contours & contourList

bbox = KLEE_savedTracing.bbox;

% Fix inconsistency between contourList & contours z-position
toDel = zeros(size(KLEE_savedTracing.contourList,1),1);
for i=1:size(KLEE_savedTracing.contourList,1)
	if isempty(KLEE_savedTracing.contours{i})
		toDel(i) = 1;
	else
		if mean(KLEE_savedTracing.contours{i}(:,3)) ~= KLEE_savedTracing.contourList(i,2)
        		warning('Something wrong with z-Postion');
        		% Fix it by trusting contourList over contours
        		KLEE_savedTracing.contours{i}(:,3) = KLEE_savedTracing.contourList(i,2);
		end
	end
end

idx = find(toDel);
KLEE_savedTracing.contours(idx) = [];
KLEE_savedTracing.contourList(idx,:) = [];
KLEE_savedTracing.contourComment(idx) = [];
KLEE_savedTracing.contourTimeStamp(idx,:) = [];

end

