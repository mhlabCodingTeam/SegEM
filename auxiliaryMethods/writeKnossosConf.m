function writeKnossosConf( savePath, expName, boundary, scale, magnification)
%writeKnossosConf( savePath, expName, boundary, scale, magnification )
%   Write KNOSSOS configuration file
fid = fopen(fullfile(savePath, 'knossos.conf'), 'w');
if fid==-1
    warning(['Could not write ' fullfile(savePath, 'knossos.conf')])
else
    fprintf(fid, 'experiment name "%s";\n', expName);
    fprintf(fid, 'boundary x %i;\n', boundary(1));
    fprintf(fid, 'boundary y %i;\n', boundary(2));
    fprintf(fid, 'boundary z %i;\n', boundary(3));
    fprintf(fid, 'scale x %4.2f;\n', scale(1));
    fprintf(fid, 'scale y %4.2f;\n', scale(2));
    fprintf(fid, 'scale z %4.2f;\n', scale(3));
    fprintf(fid, 'magnification %i;\n', magnification);
    fclose(fid);
end
end