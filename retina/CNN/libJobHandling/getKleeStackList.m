function [ dataRaw, dataTrace ] = getKleeStackList()
%[ dataRaw, dataTrace ] = getKleeStackList()
%   Creates two cell arrays with raw and traing data

% Parameters for file name generation
pathRaw = '/zdata/manuel/e_k0563/KLEEcubes/';
rawPre = 'e_k0563_ribbon_';
rawSuf = '_raw.mat';
pathTracing = '/zdata/manuel/e_k0563/tracing/KLEE/stackLocalCoordsXYcorrected/';
startIndex = 16;

files = dir([pathTracing '*.mat']);
dataRaw = cell(length(files),1);
dataTrace = cell(length(files),1);
for i=1:length(files)
    dataRaw{i} = fullfile(pathRaw, [rawPre files(i).name(startIndex:startIndex+3) rawSuf]);
    dataTrace{i} = fullfile(pathTracing, files(i).name);
end

end

