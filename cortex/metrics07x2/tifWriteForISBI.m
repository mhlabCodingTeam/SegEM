function tifWriteForISBI( imgdata, filename )

% Open file for writing
tifFile = Tiff(filename, 'w');

% Settings for writing Tif (all necessary?)
tagstruct.ImageLength = size(imgdata,1);
tagstruct.ImageWidth = size(imgdata,2);
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.Compression = Tiff.Compression.None;
tagstruct.BitsPerSample = 32;
tagstruct.SamplesPerPixel = 1;
tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
tagstruct.RowsPerStrip = size(imgdata,1);
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;

for i=1:size(imgdata,3)
    tifFile.setTag(tagstruct);
    tifFile.write(imgdata(:,:,i));
    tifFile.writeDirectory;
end
tifFile.close();

end

