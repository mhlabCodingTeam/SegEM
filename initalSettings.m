% Use jobMangerName as global variable, will be set in installer
global jobManagerName;

% A GUI to set releveant directories, Matlab jobmanager and chose a dataset
iHandle = installer;
waitfor(iHandle);
clear iHandle;

% NO MODIFICATIONS NECESSARY UNDER THIS LINE USUALLY

% Compile functions needed later using Matlab mex compiler
display('If you get warning or errors here, please try to run mex -setup and choose a compiler supported by Matlab');
% Compile mex watershed and nml parser
if strcmp(computer('arch'), 'glnxa64')
    % Linux mex
    mex CFLAGS="\$CFLAGS -U FORTIFY_SOURCE -std=c99" -largeArrayDims -outdir retina/segmentation/watershedBasedSeg retina/segmentation/watershedBasedSeg/watershed_threeTimes3D.c;
    mex -outdir auxiliaryMethods auxiliaryMethods/parseNml.c;
elseif strcmp(computer('arch'), 'PCWIN64') || strcmp(computer('arch'), 'win64') % Matlab docu inconsitent
    % Windows mex (was not able to get watershed compile using Windows SDK
    % 7.1 C-compiler (does not support C99 standard?). Works using c++
    % compiler, weird behaviour
    mex -largeArrayDims -outdir retina\segmentation\watershedBasedSeg retina\segmentation\watershedBasedSeg\watershed_threeTimes3D.cpp;
    mex -outdir auxiliaryMethods auxiliaryMethods\parseNml.c;
else
    display('Please set up mex to run with your architecture!')
end

% This requires that matlab is started from the baseDirectory of the github
% repo, better alternative?
codeDirectory = pwd;

% Open relevant scripts for dataset/code version
if strcmp(chosenDataset, 'Legacy version (for retina dataset e_k0563)')
    run(['retina' filesep 'startup.m']);
end
if strcmp(chosenDataset, 'SegEM')
    run(['cortex' filesep 'startup.m']);
end
