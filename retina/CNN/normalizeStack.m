function out = normalizeStack( in )
%out = normalizeStack( in ) Subtract mean and devide by std
out = in-mean(in(:));
out = out/std(out(:));
end

