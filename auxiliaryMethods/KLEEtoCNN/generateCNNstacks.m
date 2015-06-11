function generateCNNstacks()
% Thres defines cutoff in distance transform of labeled cells (thereby defining extracellular border in untraced regions)

settings.rawDir = '/zdata/manuel/data/cortex/2012-09-28_ex145_07x2_corrected/color/1/';
settings.rawPrefix = '2012-09-28_ex145_07x2_corrected_mag1';
settings.sourceDir = '/zdata/manuel/data/cortex/originalKLEE/';
dateStr = datestr(clock, 30);
settings.stackDir = ['/zdata/manuel/data/cortex/' dateStr  '/stackKLEE/'];
settings.targetDir = ['/zdata/manuel/data/cortex/' dateStr  '/targetKLEE/'];
settings.metaFile = ['/zdata/manuel/data/cortex/' dateStr '/parameter.mat'];
settings.border = [50; 50; 25];

% Make directories
if ~exist(settings.stackDir)
	mkdir(settings.stackDir);
end
if ~exist(settings.targetDir)
	mkdir(settings.targetDir);
end

% Locate KLEE files from database & analyze
files = dir([settings.sourceDir '3_15_*.mat']);
stacksMR = selectFiles(files);
files2 = dir([settings.sourceDir '*corrected.mat']);
stacksHD = selectFilesHD(files2);
stacks = [stacksMR stacksHD];

for i=1:length(stacks)
	display(['Processing stack ' num2str(i) '/' num2str(length(stacks))]);
	load([settings.sourceDir stacks(i).filename]);
   	[stack, bbox] = convertKleeTracingToLocalStack( KLEE_savedTracing );
	save([settings.stackDir num2str(stacks(i).taskID) '.mat'], 'stack');
	stacks(i).stackFile = [settings.stackDir num2str(stacks(i).taskID) '.mat'];
	target = xyzMaskIntraExtra(stack, 10);
	bboxRaw = bbox([2 1 3],:) + [-settings.border settings.border];
	raw = readKnossosRoi(settings.rawDir, settings.rawPrefix, bboxRaw);
	save([settings.targetDir num2str(stacks(i).taskID) '.mat'], 'raw', 'target');
	stacks(i).targetFile = [settings.targetDir num2str(stacks(i).taskID) '.mat'];
	stacks(i).bbox = bbox;
	stacks(i).bboxRaw = bboxRaw;
end

% Save all relevant meta information
save(settings.metaFile, 'stacks', 'settings');

end

