function makeMovie( raw, outputFile )
% make video of raw data + seg video

if strcmp(computer('arch'), 'glnxa64')
    writerObj = VideoWriter(outputFile, 'Motion JPEG AVI');
elseif strcmp(computer('arch'), 'PCWIN64') || strcmp(computer('arch'), 'win64')
    writerObj = VideoWriter(outputFile);
else
    error('Please set up video codex compatible with your architecture here!')
end

maxVal = max(raw(:));
minVal = min(raw(:));
raw = raw - minVal;
raw = raw ./ (maxVal - minVal);

writerObj.FrameRate = 4;
open(writerObj);
% Write each z-layer as one video frame
for f=1:size(raw,3)
    writeVideo(writerObj,raw(:,:,f));
end
close(writerObj);
close all;

end

