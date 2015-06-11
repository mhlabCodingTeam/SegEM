function generateCNNcontrol(thres)
% Thres defines cutoff in distance transform of labeled cells (thereby defining extracellular border in untraced regions)

settings.rawDir = '/zdata/manuel/data/cortex/2012-09-28_ex145_07x2/mag1/';
settings.rawPrefix = '2012-09-28_ex145_07x2_mag1';
settings.sourceDir = '/zdata/manuel/data/cortex/Korrektur/';
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
files = dir([settings.sourceDir '*.mat']);
stacks = selectFiles(files);

for i=1:length(stacks)
	display(['Processing stack ' num2str(i) '/' num2str(length(stacks))]);
	load([settings.sourceDir stacks(i).filename]);
   	[stack, bbox] = convertKleeTracingToLocalStack( KLEE_savedTracing );
	target = xyzMaskIntraExtra(stack,thres);
	bbox = bbox([2 1 3],:);
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

% Save all relevant meta information
save(settings.metaFile, 'stacks', 'settings');

end

