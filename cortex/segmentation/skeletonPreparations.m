% This script preprocesses (limits to bounding box, switch to local 
% coordinates of training region and removes glia cells and bounding box

% Skeleton locations
skelPath = [dataDirectory 'supplement' filesep 'extracted' filesep];
% Copy all skeletons to output directory
copyfile([skelPath '*.nml'], [outputDirectory filesep]);
% Load skeletons from output directory, only cortex will be preprocessed
% here, for retina see legacy version
skelFile{1} = [outputDirectory 'cortex_training.nml'];
skelFile{2} = [outputDirectory 'cortex_test.nml'];
skelFile{3} = [outputDirectory 'retina_training_local_subsampled.nml'];
skelFile{4} = [outputDirectory 'retina_test_local_subsampled.nml'];
% Skeleton bounding boxes (for cortex only, see legacy version for analog
% retina processing which was still based on dense tracings aligned to
% KNOSSOS cubes instead of arbitrary coordiantes (see
% [SegEM]/retina/segmentation/mainSeg_legacy);
bbox{1} = [4097 4737; 4481 5249; 2250 2451];
bbox{2} = [1417 1717; 4739 5039; 890 1190];
% Parse files to matlab structure
skel = cell(length(skelFile),1);
for i=1:length(skelFile)
    skel{i} = parseNml(skelFile{i});
end

%% Create version of each skeleton in local coordinates of training region and clip to bounding box 
for i=1:2
    % Save parameter attachted to first tree in skeleton collection
    savePar = skel{i}{1}.parameters;
    % Remove annotations of glia cells
    skel{i} = removeGlia(skel{i});
    % Remove annotation of bounding box (if present, outdated from old
    % oxalis version)
    skel{i} = removeBbox(skel{i});
    % Remove all empty trees in struct
    skel{i} = removeEmptySkeletons(skel{i});
    % Switch to coordinates of small subcube (offset has to be inital voxel of
    % bbox - [1 1 1] due to one index of matlab (another [1 1 1] if tracing was done in oxalis)
    skel{i} = switchToLocalCoords_v2(skel{i}, bbox{i}(:,1)' - [2 2 2]);
    % Remove all nodes outside small subcube
    skel{i} = correctSkeletonsToBBox_v2(skel{i}, bbox{i}(:,2)' - bbox{i}(:,1)');
    % Remove again in case trees are empty
    skel{i} = removeEmptySkeletons(skel{i});
    % Resore parameter in case first tree got gone
    skel{i}{1}.parameters = savePar;
    % Write local version of skeleton
    writeNml(strrep(skelFile{i}, '.', '_local.'), skel{i});
end

%% Equalize inter-node distance for all skeletons
skel = equalizeSkeletons(skel);

%% Write equalized cortex skeletons to folder
for i=1:2
    writeNml(strrep(skelFile{i}, '.', '_local_subsampled.'), skel{i});
end

%% Calculate some statistics on all skeletons
skeletonStatistics(outputDirectory);
