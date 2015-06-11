function convertTestSetFromKLEETracingToLabelmatrix(settings)
% For folder location see start of function, will probably need changes,
% thres = cutoff in distance transform of labeled cells

% Make directories
if ~exist(settings.stackDir, 'dir')
	mkdir(settings.stackDir);
end
if ~exist(settings.targetDir, 'dir')
	mkdir(settings.targetDir);
end

% Locate KLEE files from database & analyze
files = dir([settings.sourceDir '*.mat']);
stacks = selectFiles(files);

for i=1:length(stacks)
	display(['Processing stack ' num2str(i) '/' num2str(length(stacks))]);
	load([settings.sourceDir stacks(i).filename]);
   	[stack, bbox] = convertKleeTracingToLocalStack( KLEE_savedTracing );
	target = xyzMaskIntraExtra(stack,settings.cutoffDistance);
	bboxRaw = bbox + [-settings.border settings.border];
	rawBig = readKnossosRoi(settings.rawDir, settings.rawPrefix, bboxRaw);
	raw = readKnossosRoi(settings.rawDir, settings.rawPrefix, bbox);
	save([settings.stackDir num2str(stacks(i).taskID) '.mat'], 'raw', 'stack');
	save([settings.targetDir num2str(stacks(i).taskID) '.mat'], 'rawBig', 'target');
	stacks(i).stackFile = [settings.stackDir num2str(stacks(i).taskID) '.mat'];
	stacks(i).targetFile = [settings.targetDir num2str(stacks(i).taskID) '.mat'];
	stacks(i).bbox = bbox;
	stacks(i).bboxRaw = bboxRaw;
end

% Save relevant meta information
save(settings.metaFile, 'stacks', 'settings');

end

