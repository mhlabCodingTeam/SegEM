function onlyFwdPass3DonKnossosFolder(cnet, gpuSwitch, input, result, bbox)

% Choose the right GPU if switch is set
if gpuSwitch
    w = getCurrentWorker();
    w = w.Name;
    gselect(str2double(w(end-1:end)));
end

% Set activity class of CNN
if gpuSwitch
    cnet.run.actvtClass = @gpuarray;
else
    cnet.run.actvtClass = @single;
end

% Load data with right border for cnet
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
classification = onlyFwdPass3D(cnet, raw);
% Save result to KNOSSOS folder
writeKnossosRoi(result.root, result.prefix, bbox(:,1)', classification, 'single');

end
