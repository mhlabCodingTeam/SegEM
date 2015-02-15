function cnet = trainGradient(cnet, rawData, tracedData, run)

w = getCurrentWorker();
if ~isempty(w)
    w = w.Name;
    gselect(str2double(w(16:17)));
end
% Transfer run to cnet.run (which will be used in this function; cnet.run
% can also be defined before hand)
if(nargin==4)
    cnet.run=run;
end

% Check whether direactory exsist and create otherwise
if(~exist(fullfile(cnet.run.savingPath),'dir'))
    mkdir(fullfile(cnet.run.savingPath));
end

for iid1 = 1:cnet.run.maxIter
    % Set up counter and cell array for erros within GPU task of current minicube
    nrFails = 0;
    failReport = {};
    % Choose minicube randomly
    currentIndex = ceil(length(rawData)*rand);
    % For debuging pourpes learn with only one minicube
    if cnet.run.debug
        currentIndex=2;
    end
    % Loads variable kl_roi
    load(rawData{currentIndex});
    % Loads variable kl_stack (or KLEE_savedStack)
    load(tracedData{currentIndex});
    if(exist('KLEE_savedStack','var') && ~exist('kl_stack','var'))
        kl_stack=KLEE_savedStack;
        clear('KLEE_savedStack');
    end
    % Create Task on jobmanager if running on cluster, otherwise just call
    % learn
	[cnet, error, randEdges, rngState] = cnet.learn( kl_roi, kl_stack);
    % Save some data
    currentStack = rawData{currentIndex};
    cnet = cnet.forAll(cnet.run.saveTyp);
    save(fullfile(cnet.run.savingPath,[ 'saveNet' num2str(iid1, '%010.0f') '.mat']), 'cnet', 'failReport', 'currentStack', 'rngState', 'error', 'randEdges');
    if(~cnet.run.local)
        system(['chmod 664 ' fullfile(cnet.run.savingPath,[ 'saveNet' num2str(iid1, '%010.0f') '.mat'])]);
    end
end
