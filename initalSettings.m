global jobManagerName;
% Set dataLocation (where to find datasets, skeletons, trained CNNs etc
% here as well as a ouput directory to store computed results and a WORKING
% Matlab Cluster configuration, FURTHERMORE make sure than mex command in
% matlab for compiling c-files is working

% Supplementary data, Online Material and Datasets: Currently still resides on FS Frankfurt
% on FS Frankfurt, no local copy will be generated due to size
% with /home/mberning/fsHest/ = /storage.hest.corp.brain.mpg.de/Data
dataDirectory = '/home/mberning/fsHest/Data/berningm/20150205paper1submission/';
% which jobmanager to use for processing , has to be set in matlab
% local is usually there by default
jobManagerName = 'local';
% working directory (for output, e.g. trained CNN, visualizations, ...)
outputDirectory = '/home/mberning/localStorage/data/SegEM/';

% NO MODIFICATIONS NECESSARY UNDER THIS LINE USUALLY

display('If you get warning or errors here, please try to run mex -setup and choose a compiler supported by Matlab');
% Compile mex watershed and nml parser
if strcmp(computer('arch'), 'glnxa64')
    % Linux mex
    mex CFLAGS="\$CFLAGS -U FORTIFY_SOURCE -std=c99" -largeArrayDims -outdir retina/segmentation/watershedBasedSeg retina/segmentation/watershedBasedSeg/watershed_threeTimes3D.c;
    mex -outdir auxiliaryMethods auxiliaryMethods/parseNml.c;
elseif strcmp(computer('arch'), 'PCWIN64')
    % Windows mex
    mex -largeArrayDims -outdir retina\segmentation\watershedBasedSeg retina\segmentation\watershedBasedSeg\watershed_threeTimes3D.c;
    mex -outdir auxiliaryMethods auxiliaryMethods\parseNml.c;
else
    display('Please set up mex to run with your architecture!')
end

% This requires that matlab is started from the baseDirectory of the github
% repo, better alternative?
codeDirectory = pwd;

% User interaction, choose which dataset/code version to work with
button = questdlg('Which data do you want to look at?', ...
    'Choose dataset', 'Retina (ek0563)', 'Cortex (2012_09_28_ex145_07x2)', 'Retina (ek0563)');
if strcmp(button, 'Retina (ek0563)')
    run(['retina' filesep 'startup.m']);
end
if strcmp(button, 'Cortex (2012_09_28_ex145_07x2)')
    run(['cortex' filesep 'startup.m']);
end
clear button;

