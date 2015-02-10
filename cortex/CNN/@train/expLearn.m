function [currentW, currentB] = expLearn(obj,layer)
	% factor 6.9 to have 1 promille of starting values at the end of training
	currentW = obj.wStart(layer)*exp(-6.9*obj.iterations/obj.maxIter);
	currentB = obj.bStart(layer)*exp(-6.9*obj.iterations/obj.maxIter);
end
    
