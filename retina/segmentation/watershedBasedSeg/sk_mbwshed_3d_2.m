function marker_image = sk_mbwshed_3d_2( xmap, ymap, zmap, marker_image, bins )

misize = size(marker_image);
queues = cell(bins,2);
coords = [-1 0 0; 0 -1 0; 0 0 -1; 1 0 0; 0 1 0; 0 0 1];

% Generate priority queues
labelled_pixel = find(marker_image > 0);
for i=1:size(labelled_pixel,1)
    [x,y,z] = ind2sub(misize,labelled_pixel(i));
    if x > 1
        if marker_image(x-1,y,z) == 0
            queues{xmap(x-1,y,z),1}(end+1) = labelled_pixel(i);
            queues{xmap(x-1,y,z),2}(end+1) = 1;
        end
    end
    if y > 1
        if marker_image(x,y-1,z) == 0
            queues{ymap(x,y-1,z),1}(end+1) = labelled_pixel(i);
            queues{ymap(x,y-1,z),2}(end+1) = 2;
        end
    end
    if z > 1
        if marker_image(x,y,z-1) == 0
            queues{zmap(x,y,z-1),1}(end+1) = labelled_pixel(i);
            queues{zmap(x,y,z-1),2}(end+1) = 3;
        end
    end
    if x < misize(1)
        if marker_image(x+1,y,z) == 0
            queues{xmap(x,y,z),1}(end+1) = labelled_pixel(i);
            queues{xmap(x,y,z),2}(end+1) = 4;
        end
    end
    if y < misize(2)
        if marker_image(x,y+1,z) == 0
            queues{ymap(x,y,z),1}(end+1) = labelled_pixel(i);
            queues{ymap(x,y,z),2}(end+1) = 5;
        end
    end
    if z < misize(3)
        if marker_image(x,y,z+1) == 0
            queues{zmap(x,y,z),1}(end+1) = labelled_pixel(i);
            queues{zmap(x,y,z),2}(end+1) = 6;
        end
    end  
end
% Work through Queues
while sum(not(cellfun(@isempty,queues)))
    priority = find(~isempty(queues), 1, 'first');
    active_pixel = queues{priority,1}(1);
    neighbour = queues{priority,2}(1);
    queues{priority,1}(1) = [];
    queues{priority,2}(1) = [];
    [xA,yA,zA]=ind2sub(misize,active_pixel);
    x = xA+coords(neighbour,1);
    y = yA+coords(neighbour,2);
    z = zA+coords(neighbour,3);
    if marker_image(x,y,z) == 0
        marker_image(x,y,z) = marker_image(xA,yA,zA);
        if x > 1
            if marker_image(x-1,y,z) == 0
                queues{xmap(x-1,y,z),1}(end+1) = sub2ind(misize, x, y, z);
                queues{xmap(x-1,y,z),2}(end+1) = 1;
            end
        end
        if y > 1
            if marker_image(x,y-1,z) == 0
                queues{ymap(x,y-1,z),1}(end+1) = sub2ind(misize, x, y, z);
                queues{ymap(x,y-1,z),2}(end+1) = 2;
            end
        end
        if z > 1
            if marker_image(x,y,z-1) == 0
                queues{zmap(x,y,z-1),1}(end+1) = sub2ind(misize, x, y, z);
                queues{zmap(x,y,z-1),2}(end+1) = 3;
            end
        end
        if x < misize(1)
            if marker_image(x+1,y,z) == 0
                queues{xmap(x,y,z),1}(end+1) = sub2ind(misize, x, y, z);
                queues{xmap(x,y,z),2}(end+1) = 4;
            end
        end
        if y < misize(2)
            if marker_image(x,y+1,z) == 0
                queues{ymap(x,y,z),1}(end+1) = sub2ind(misize, x, y, z);
                queues{ymap(x,y,z),2}(end+1) = 5;
            end
        end
        if z < misize(3)
            if marker_image(x,y,z+1) == 0
                queues{zmap(x,y,z),1}(end+1) = sub2ind(misize, x, y, z);
                queues{zmap(x,y,z),2}(end+1) = 6;
            end
        end
    end
end

end

