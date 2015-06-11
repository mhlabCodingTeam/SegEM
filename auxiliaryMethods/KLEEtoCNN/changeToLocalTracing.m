function KLEE_savedTracing = changeToLocalTracing( KLEE_savedTracing, offset )

for i=1:size(KLEE_savedTracing.contourList,1)
	KLEE_savedTracing.contourList(i,2) = KLEE_savedTracing.contourList(i,2) - offset(3) + 1;
	% Undo KLEE x/y mess in each contour
	temp = KLEE_savedTracing.contours{i}(:,2) - offset(2) + 1;
	KLEE_savedTracing.contours{i}(:,2) = KLEE_savedTracing.contours{i}(:,1) - offset(1) + 1;
	KLEE_savedTracing.contours{i}(:,1) = temp;  	
	KLEE_savedTracing.contours{i}(:,3) = KLEE_savedTracing.contours{i}(:,3) - offset(3) + 1;
end

