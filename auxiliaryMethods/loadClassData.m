function class = loadClassData(root, prefix, bbox)
% Wrapper for easier loading of Knossos-Hierachy classification
class = readKnossosRoi(root, prefix, bbox, 'single', '', 'raw');
end