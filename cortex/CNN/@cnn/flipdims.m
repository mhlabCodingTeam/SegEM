function Y = flipdims(~, X)
%flips all dims of X
	Y=reshape(X(end:-1:1),size(X));
end
