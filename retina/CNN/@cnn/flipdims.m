function Y = flipdims(~, X)
%flips all dims of X
	Y=reshape(X(end:-1:1),size(X));%1.1x(1000x1000 array)-20x(5x5x5x5x5x5 array) speedup (6x at common use)
end
