function prepareSkeletons(pT)
% Performs needed operations on skeleton for use as GT: remove empty skeletons, switch & crop according to bbox, equalize inter-node distance
% Not very pretty, should be changed to skeleton class at some point

    if ~exist([pT.syncFolder 'segmentation/'], 'dir')
        mkdir([pT.syncFolder 'segmentation/']);
    end

    for i=1:length(pT.local)
        skeletonFile = pT.local(i).trainFileRaw;
        skel{i} = parseNml(skeletonFile);
        % Save parameter from first skel in case they get deleted
        savePar{i}.par = skel{i}{1}.parameters;
        savePar{i}.par.activeNode.id = '1';
        % Remove empty and bounding box skeletons
        skel{i} = removeEmptySkeletons(skel{i});
        skel{i} = removeBbox(skel{i});
        % Switch to coordinates of small subcube (offset has to be inital voxel bbox - [1 1 1] due to one index of matlab & another [1 1 1] if tracing was done in oxalis)
        skel{i} = switchToLocalCoords_v2(skel{i}, pT.local(i).bboxSmall(:,1)' - [1 1 1]);
        % Remove all nodes outside small bounding box
        skel{i} = correctSkeletonsToBBox_v2(skel{i}, pT.local(i).bboxSmall(:,2)' - pT.local(i).bboxSmall(:,1)'+ [1 1 1]);
        skel{i} = removeEmptySkeletons(skel{i});
        % Otherwise writeNml will fail
        skel{i}{1}.parameters = savePar{i}.par;
        % Write skeleton video for control of training data
        raw = loadRawData(pT.raw.root, pT.raw.prefix, pT.local(i).bboxSmall, 1);
        thisSkel = skel{i};
        save([pT.syncFolder 'segmentation/denseSkelData' num2str(i) '.mat'], 'thisSkel', 'raw')
    end
    
    % Equalize inter-node distance in different dense tracings to maximal value
    skelEq = equalizeSkeletons(skel);

    % Write local, equalized skeletons to nml
    for i=1:length(skelEq);
        skel{i} = removeEmptySkeletons(skel{i});
        skel{i}{1}.parameters = savePar{i}.par;
        % Write local version of skeleton
        writeNml(pT.local(i).trainFileLocal, skelEq{i});
    end

    %% Analog but this time use glia annotated file and remove them for neurite only split-merger curves
    for i=1:length(pT.local)
        skeletonFile = pT.local(i).trainFileGlia;
        skel{i} = parseNml(skeletonFile);
        % Save parameter from first skel in case they get deleted
        savePar{i}.par = skel{i}{1}.parameters;
        savePar{i}.par.activeNode.id = '1';
        % Remove glia from skeleton file (based on comments)
        skel{i} = removeGlia(skel{i});
        % Remove empty and bounding box skeletons
        skel{i} = removeEmptySkeletons(skel{i});
        skel{i} = removeBbox(skel{i});
        % Switch to coordinates of small subcube (offset has to be inital voxel bbox - [1 1 1] due to one index of matlab & another [1 1 1] if tracing was done in oxalis)
        skel{i} = switchToLocalCoords_v2(skel{i}, pT.local(i).bboxSmall(:,1)' - [1 1 1]);
        % Remove all nodes outside small bounding box
        skel{i} = correctSkeletonsToBBox_v2(skel{i}, pT.local(i).bboxSmall(:,2)' - pT.local(i).bboxSmall(:,1)'+ [1 1 1]);
        skel{i} = removeEmptySkeletons(skel{i});
        % Otherwise writeNml will fail
        skel{i}{1}.parameters = savePar{i}.par;
        % Write skeleton video for control of training data
        raw = loadRawData(pT.raw.root, pT.raw.prefix, pT.local(i).bboxSmall, 1);
        thisSkel = skel{i};
        save([pT.syncFolder 'segmentation/denseSkelDataGlia' num2str(i) '.mat'], 'thisSkel', 'raw')
    end

    skelWithoutGliaEq = equalizeSkeletons(skel);

    for i=1:length(skelEq);
        skel{i} = removeEmptySkeletons(skel{i});
        skel{i}{1}.parameters = savePar{i}.par;
        % Write nml with removed glia
        writeNml(pT.local(i).trainFileLocalWithoutGlia, skelWithoutGliaEq{i});
    end

end

