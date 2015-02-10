function [currentW, currentB] = linearLearn(obj,layer)
	% Learning rate will decay to zero in linear fasion
	currentW = obj.wStart(layer)-obj.wStart(layer)*obj.iterations/obj.maxIter;
	currentB = obj.bStart(layer)-obj.bStart(layer)*obj.iterations/obj.maxIter;
end

