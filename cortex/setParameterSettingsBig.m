function [parameter, parameterTrain] = setParameterSettingsBig(dataFolder, saveFolder, old_datestr)
% Function to set parameter for pipeline, give only two arguments if you want to create new parameters
% or a former datestring if you want to overwrite/continue other settings

    % Start time as unique identifier for reference and storage
    if nargin == 2
        parameter.start = datestr(clock, 30);
    elseif nargin == 3
        parameter.start = old_datestr;
    end
    parameter.saveFolder = [saveFolder parameter.start filesep];
    % Define region to put through pipeline
    parameter.bbox = [641 8320; 769 5376; 129 3200]; % this should be aligned with KNOSSOS cubes and be divisble by tileSize 
    %parameter.bbox = [3073 5120; 3073 5120; 2049 3072];
    parameter.tileSize =  [512; 512; 256]; % Size of local segmentation and local graph construction
    parameter.tileBorder = [-256 256; -256 256; -128 128]; % border of local segmentation included for gloablization and large size due to games
    parameter.tiles = (parameter.bbox(:,2) - parameter.bbox(:,1) + 1) ./ parameter.tileSize;
    % Which raw dataset
    parameter.raw.root = [dataFolder filesep 'datasets' filesep '2012-09-28_ex145_07x2_corrected' filesep 'color' filesep '1' filesep];
    parameter.raw.prefix = '2012-09-28_ex145_07x2_corrected_mag1';
    % Which classifier to use
    parameter.cnn.first = [dataFolder filesep 'supplement' filesep 'extracted' filesep 'cortex - CNN20130516T204040_8_3.mat'];
    parameter.cnn.GPU = false;
    % Function to use for classification
    parameter.class.func = @bigFwdPass;
    % Location to store CNN classification
    parameter.class.root = [parameter.saveFolder 'class/'];
    parameter.class.prefix = parameter.raw.prefix;
    % Function to use for segmentation
    parameter.seg.func = @seg20141017;
    parameter.seg.root = [parameter.saveFolder 'globalSeg/'];
    parameter.seg.prefix = parameter.raw.prefix;

    % LOCAL SETTINGS for each tile
    for i=1:parameter.tiles(1)
        for j=1:parameter.tiles(2)
            for k=1:parameter.tiles(3)
                % Save path for data relating to this tile
                parameter.local(i,j,k).saveFolder = [parameter.saveFolder 'local/' 'x' num2str(i, '%.4i') 'y' num2str(j, '%.4i') 'z' num2str(k, '%.4i') '/'];
                % Bounding box without and with border for this tile
                parameter.local(i,j,k).bboxSmall = [parameter.bbox(:,1) + [i-1; j-1; k-1] .* parameter.tileSize parameter.bbox(:,1) + [i; j; k] .* parameter.tileSize - [1; 1; 1]];
                parameter.local(i,j,k).bboxBig = parameter.local(i,j,k).bboxSmall + parameter.tileBorder;
                % Where to save
                parameter.local(i,j,k).segFile = [parameter.local(i,j,k).saveFolder 'seg.mat'];
            end
        end
    end

    % GLOBAL SETTINGS FOR training data generation
    parameterTrain = parameter;
    % Remove all fields that do not make sense in training data setting
    parameterTrain = rmfield(parameterTrain, {'local' 'bbox' 'tileSize' 'tiles'});
    parameterTrain.cnn.GPU = false;

    % Densly skeletonized regions in dataset
    skeletonFolder = [dataFolder filesep 'supplement' filesep 'extracted' filesep];
    % Region from Heiko
    parameterTrain.local(1).bboxSmall = [4097 4736; 4481 5248; 2250 2450];
    parameterTrain.local(1).trainFileRaw = [skeletonFolder filesep 'cortex_training.nml'];
    parameterTrain.local(1).trainFileLocal = [skeletonFolder filesep 'cortex_training_local.nml'];
    parameterTrain.local(1).trainFileLocalSubsampled = [skeletonFolder filesep 'cortex_training_local_subsampled.nml'];
    % Region from Alex
    parameterTrain.local(2).bboxSmall = [1417 1717; 4739 5039; 890 1190];
    parameterTrain.local(2).trainFileRaw = [skeletonFolder filesep 'cortex_test.nml'];
    parameterTrain.local(2).trainFileLocal = [skeletonFolder filesep 'cortex_test_local.nml'];
    parameterTrain.local(2).trainFileLocalSubsampled = [skeletonFolder filesep 'cortex_test_local_subsampled.nml'];

    % LOCAL SETTINGS FOR training tiles
    for i=1:2
        % Save path for data relating to this tile
        parameterTrain.local(i).saveFolder = [parameterTrain.saveFolder 'train' num2str(i, '%.4i') '/'];
        % Where to save
        parameterTrain.local(i).class.root = [parameterTrain.local(i).saveFolder 'class/'];
        parameterTrain.local(i).class.prefix = parameterTrain.class.prefix;
        parameterTrain.local(i).seg.parameterSearchFolder = [parameterTrain.local(i).saveFolder 'parameterSearch/'];
        parameterTrain.local(i).segFile = [parameterTrain.local(i).saveFolder 'seg.mat'];
    end
    
    % Create folder if it does not exist
    if ~exist(parameter.saveFolder, 'dir');
        mkdir(parameter.saveFolder);
    end
    
    % Save everything
%     pT = parameterTrain;
%     p = parameter;
%     save([parameter.saveFolder filesep 'allParameter.mat'], 'p', 'pT');

end

