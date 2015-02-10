global jobManagerName;
% Set dataLocation (where to find datasets, skeletons, trained CNNs etc
% here as well as a ouput directory to store computed results and a WORKING
% Matlab Cluster configuration

% Supplementary data, Online Material and Datasets: Currently still resides on FS Frankfurt
% on FS Frankfurt, no local copy will be generated due to size
% with /home/mberning/fsHest/ = /storage.hest.corp.brain.mpg.de/Data
dataDirectory = '/home/mberning/fsHest/Data/berningm/20150205paper1submission/';
% which jobmanager to use for processing , has to be set in matlab
% local is usually there by default
jobManagerName = 'local';
% working directory (for output, e.g. trained CNN, visualizations, ...)
outputDirectory = '/home/mberning/localStorage/data/SegEM/';

% NO MODIFICATIONS NECESSARY UNDER THIS LINE


% Compile mex watershed 
% %Linux mex
mex CFLAGS="\$CFLAGS -U FORTIFY_SOURCE -std=c99" -outdir retina/segmentation/watershedBasedSeg -largeArrayDims retina/segmentation/watershedBasedSeg/watershit_3D.cpp;
% %Windows mex (to comply with C99 standard C++ used)
% mex -largeArrayDims -outdir segmentation/ segmentation/watershit_3D.cpp;

% ... and nml parser
mex -outdir auxiliaryMethods auxiliaryMethods/parseNml.c;

codeDirectory = pwd;

% User interaction, choose which dataset/code version to work with
button = questdlg('Which data do you want to look at?', ...
    'Choose dataset', 'Retina (ek0563)', 'Cortex (2012_09_28_ex145_07x2)', 'Retina (ek0563)');
if strcmp(button, 'Retina (ek0563)')
    run retina/startup.m
end
if strcmp(button, 'Cortex (2012_09_28_ex145_07x2)')
    run cortex/startup.m
end
clear button;

