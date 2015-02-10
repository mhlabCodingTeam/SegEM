function fwdPass3DonKhierachy(cnet, input, result, bbox)
% Forward pass only directly on KNOSSOS Hierachy

% Load data with right border for cnet to produce output at 'bbox'
bboxWithBorder(:,1) = bbox(:,1) - ceil(cnet.randOfConvn'/2);
bboxWithBorder(:,2) = bbox(:,2) + ceil(cnet.randOfConvn'/2);
raw = readKnossosRoi(input.root, input.prefix, bboxWithBorder);
% Normalize data
if cnet.normalize
	raw = normalizeStack(single(raw));
else
	raw = single(raw);
end
% Memory efficent fwd pass
class = onlyFwdPass3D(cnet, raw);
% Save result to KNOSSOS folder
writeKnossosRoi(result.root, result.prefix, bbox(:,1)', single(class), 'single');

end
