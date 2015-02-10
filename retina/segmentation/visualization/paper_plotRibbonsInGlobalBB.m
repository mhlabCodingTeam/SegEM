%% Information about gloabal position of training data

data = xlsread('/p/Ribbon0001-0232_Knossoscoords.xls');

%% Load stacks to check whether they were used
ribbonDir = '/data/e_k0563/local/stacksTrace/';
files = dir([ribbonDir '*.mat']);
ribbonsWithErrors = [6 26 64 106 130 131 132 159 163 183 186];

%% Compare which ribbons are in all three sets (file exists & global position is known & did not have an error)
globalPosition = ~isnan(mean(data,2));
fileExist = zeros(length(globalPosition),1);
for i=1:length(files)
    fileExist(str2double(files(i).name(16:19))) = 1;
end
noError = ones(length(globalPosition),1);
noError(ribbonsWithErrors) = 0;
        
% Flächen der Würfel, siehe Hilfe zu patch und Multifaceted Patches 
faces = [1 2 6 5;2 3 7 6;3 4 8 7;4 1 5 8;1 2 3 4;5 6 7 8]; 
% PLot the boundingBoxes
maxID = min([length(fileExist) length(noError) length(globalPosition)]);
figure;
a = 0;
for i=1:maxID
    if fileExist(i) > 0 && noError(i) > 0 && globalPosition(i)
        a = a + 1;
        load([ribbonDir 'e_k0563_ribbon_' num2str(i, '%.4i') '_fused.mat']);
        this_EdgeLength = size(kl_stack); 
        d = (this_EdgeLength-1)/2;
        x = data(i,2);
        y = data(i,3);
        z = data(i,4);
        vertices(:,1,:)=[x-d;x+d;x+d;x-d;x-d;x+d;x+d;x-d]; 
        vertices(:,2,:)=[y-d;y-d;y+d;y+d;y-d;y-d;y+d;y+d]; 
        vertices(:,3,:)=[z-d;z-d;z-d;z-d;z+d;z+d;z+d;z+d]; 

        % Zeichnen der Würfel 
        patch('Vertices',vertices(:,:,k),'Faces',faces,'FaceAlpha',0.5,... 
            'FaceColor','flat','FaceVertexCData',hsv(6));

    end
end
daspect([25 25 12]);
grid on;
view(3);
xlabel('x');
ylabel('y');
zlabel('z');
display(num2str(a))

% for j=1:36
%     camorbit(10,0); pause(.5);
% end
% close all;
