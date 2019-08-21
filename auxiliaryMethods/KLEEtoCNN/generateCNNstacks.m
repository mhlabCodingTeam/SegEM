function generateCNNstacks()

settings.sourceDir = '/gaba/u/mberning/data/cortex/originalKLEE/';
settings.targetDir.root = '/tmpscratch/webknossos/Connectomics_Department/2012-09-28_ex145_07x2_segEM_training_data_no_erosion/segmentation/1/';
settings.targetDir.backend = 'wkwrap';

% Locate KLEE files from database & analyze
files = dir([settings.sourceDir '3_15_*.mat']);
stacksMR = selectFiles(files);
files2 = dir([settings.sourceDir '*corrected.mat']);
stacksHD = selectFilesHD(files2);
stacks = [stacksMR stacksHD];

wkwInit('new', settings.targetDir.root, 32, 32, 'uint32', 1);

for i=1:length(stacks)
	display(['Processing stack ' num2str(i) '/' num2str(length(stacks))]);
	load([settings.sourceDir stacks(i).filename]);
   	[stack, bbox] = convertKleeTracingToLocalStack( KLEE_savedTracing );
	stacks(i).bbox = bbox;
    display(bbox);
    % Save stack to original position in segmentation layer defined above as target dir in wkw format
    saveSegDataGlobal(settings.targetDir, bbox(:,1), stack);
end

% Save all relevant meta information
writeJson(fullfile(settings.targetDir.root, 'stacks.json'), stacks);

end

