function saveJobParamToXls( cnet, folder )
%function saveJobParamToXls( cnet, folder )
%   Save CNN parametrs to Excel File
if ~exist(folder,'dir')
    mkdir(folder);
end
fid = fopen([folder 'parameter.xls'], 'a');
par = fieldnames(cnet);
for i=1:length(par)
    if ~strcmp(par{i},'run') && ~strcmp(par{i}, 'layer')
        if strcmp(class(cnet.(par{i})), 'function_handle')
            fprintf(fid, '%s\t', func2str(cnet.(par{i})));
        elseif isnumeric(cnet.(par{i}))
            fprintf(fid, '%s\t', num2str(cnet.(par{i})));
        else
            fprintf(fid, '%s\t', cnet.(par{i}));
        end
    end
end
parRun = fieldnames(cnet.run);
for i=1:length(parRun)
    if strcmp(class(cnet.run.(parRun{i})), 'function_handle')
        fprintf(fid, '%s\t', func2str(cnet.run.(parRun{i})));
    elseif isnumeric(cnet.run.(parRun{i}))
        fprintf(fid, '%s\t', num2str(cnet.run.(parRun{i})));
    else
        fprintf(fid, '%s\t', cnet.run.(parRun{i}));
    end
end
fprintf(fid, '\n');
fclose(fid);

end

