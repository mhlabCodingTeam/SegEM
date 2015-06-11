function target = xyzMaskIntraExtra( stack, thres )
	target = int8(stack > 0);
	distField = bwdist(stack);
	target(distField < thres & target == 0) = -1;
end

