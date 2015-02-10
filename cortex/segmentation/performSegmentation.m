function job = performSegmentation(paramCell, inputFile, outputFile)
    % For each training region and radius for morphological reconstruction:
    % Perform parameter search as defined in parameters pS

    load(inputFile);
    % segment and evaluate performance for each set of parameter
    %scan
    fun = paramCell{1};
    segmentation = fun(affReconRecon,paramCell{2});
    save(outputFile, 'segmentation');

end

