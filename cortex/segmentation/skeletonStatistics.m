function skeletonStatistics(directory)
% Calculate some basic statistics of skeletons with a folder and save to file

    files = dir([directory '*.nml*']);
    fid = fopen([directory 'statistics.txt'], 'a');
    fprintf( fid, ['Skeleton statistics from date: ' datestr(clock, 30) '\n']);
    fprintf( fid, '\n');
    for i=1:length(files)
        skel = parseNml([directory files(i).name]);
        nodes = [];
        for tree=1:length(skel)
            nodes = [nodes; skel{tree}.nodes];
        end
        scale = [str2num(skel{1}.parameters.scale.x) str2num(skel{1}.parameters.scale.y) str2num(skel{1}.parameters.scale.z)];
        stat.nrNodes = size(nodes,1);
        stat.volumeBbox = prod((max(nodes(:,1:3)) - min(nodes(:,1:3)) + [1 1 1]) .* scale)/1e9;
        stat.pathLength = getPathLength(skel);
        stat.pathDensity = stat.pathLength./stat.nrNodes;
        stat.volumeDensity = stat.pathLength./stat.volumeBbox;
        fprintf( fid, [files(i).name ':\n' ]);
        fprintf( fid, ['Number nodes: ' num2str(stat.nrNodes) '\n']);
        fprintf( fid, ['Volume of axis-aligned bbox [microns^3]: ' num2str(stat.volumeBbox, '%.2i') '\n' ]);
        fprintf( fid, ['Path length of skeletons [mm]: ' num2str(stat.pathLength/1e6, '%.2i') '\n' ]);
        fprintf( fid, ['Average path length between nodes [nm]: ' num2str(stat.pathDensity, '%.2i') '\n' ]);
        fprintf( fid, ['Path length per volume [microns/microns^3]: ' num2str(stat.volumeDensity/1e3, '%.2i') '\n' ]);
        fprintf( fid, '\n');
    end
    fprintf( fid, '\n');
    fclose(fid);
end

