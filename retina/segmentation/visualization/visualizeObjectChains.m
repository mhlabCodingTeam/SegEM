function [ output_args ] = visualizeObjectChainsP( input_args )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
for chain=1:100

    % Randomizer
    while true
       randSkel = ceil(length(nodes)*rand(1));
       if ~isempty(nodes{randSkel})
           if size(skel{randSkel}.edges,1) > 2
               whichSkel  = randSkel;
               display(['Skelett: ' num2str(whichSkel)]);
               break;
           end
       end
    end
    se = seg{1,3,1};
    load segColormap.mat;
    sk = nodes{whichSkel};
    ske = skel{whichSkel}.edges;
    slices = {[] [] 10:40:250};

    objects = unique(se(sub2ind(size(se),sk(:,1),sk(:,2),sk(:,3))));
    objects(objects == 0) = [];
    labelAt = [100 200 300];
    close all;
    f = figure('Position', [1601 133 1024 692], 'Renderer', 'OpenGL', 'Visible', 'off' );
    views = {2, 3, [90,0]};
    for subp=1:3
        subplot(1,3,subp);
        hold on;
        for i=1:length(objects)
            obj = se == objects(i);
            display(num2str(i));
            issf = isosurface(obj, .1);
            k{i} = patch(issf);
            set(k{i}, 'FaceColor', c(mod(i-1,31)+1,:), 'EdgeColor', 'none');
        end

        for i=1:size(ske,1)
            plot3(sk([ske(i,1) ske(i,2)],2), sk([ske(i,1) ske(i,2)],1), sk([ske(i,1) ske(i,2)],3), '-r', 'LineWidth', 3);
        end
%         plot3([1 384],[384 384],[384 384], 'k');
%         plot3([384 384], [1 384],[384 384], 'k');
%         plot3([384 384], [384 384], [1 384], 'k');
    %     r = plotOriginalData(double(raw), slices);
        view(views{subp});
        daspect([25 25 12]);
        title(['Skelett: ' num2str(whichSkel)]);
    %     axis off;
        grid on;
        %axis vis3d;
        alpha(.7);
        xlim([1 384]);
        ylim([1 384]);
        zlim([1 384]);
        %zoom(1.5);
        light = camlight('headlight');
        lighting phong;
    end
%     % Fly around
%     for i=1:36
%        camorbit(10,0,'data')
%        camlight(light, 'headlight')
% %        switchVisibility(k, 1)
%        drawnow
%     end
%     set(f,'PaperPositionMode','auto')
    


    set(f,'PaperPositionMode', 'manual', 'PaperUnits','centimeters', ...
    'Paperposition',[1 1 28 20], 'PaperSize', [29.2 21])
     drawnow; pause(.3);
     %orient landscape;
%     saveas(gcf, ['object_chains/chain' num2str(chain, '%4.4i') '.pdf'])
    print(f, '-dpdf', '-r300', ['/mnt/backup/manuel/object_chains/chain' num2str(chain, '%4.4i')]);
    %pause;

end

end

