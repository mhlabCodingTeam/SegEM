function makeOriginalDataMovie( rawData )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
close all;
figure('Position', [100 100, 640 400], 'Renderer', 'OpenGL');
nrMovieFrames = 60;

% Create 3D Point Cloud Plot of data 
[X,Y,Z] = meshgrid(linspace(1,257,257),linspace(1,257,257),linspace(1,257,257));
scatter3(X(:),Y(:),Z(:),115,rawData(:), 's', 'filled');
set(gca,'NextPlot','replacechildren');
xlim([1 size(rawData,1)]);
ylim([1 size(rawData,1)]);
zlim([1 size(rawData,1)]);
set(gcf, 'Color', 'w');
daspect([25 25 25]);
axis off;
colormap(gray(256));
set(gca, 'CameraViewAngle', 4);
campos([-50 128 128]);
camtarget([374 128 128]);

% for i=1:nrMovieFrames 
%     print(gcf, '-djpeg', '-r50', ['soonToBeMovie' num2str(i, '%04.0f') '.jpg']);
%     campan(1,0);
% end

end
