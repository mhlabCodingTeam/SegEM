function  writeKnossosRoi( kl_parfolder, kl_fileprefix, kl_roiStart, kl_data, classT, kl_filesuffix, options )

% WRITEKNOSSOSROI(KL_PARFOLDER, KL_FILEPREFIX, KL_ROISTART, KL_DATA): Write large data from Malab into multiple .raw files by
%   giving the start coordinates of the cube. The precision used is an
%   unsigned integer with 8 bits.
%   
%   The function has the following arguments:
%       KL_PARFOLDER: Give the root directory where you want the files to be
%           saved as a string, e.g. 'E:\e_k0563\k0563_mag1\'
%       KL_FILEPREFIX: Give the name with which you want the files to be saved without
%           the coordinates or the ending as a string, e.g.0 '100527_k0563_mag1'
%       KL_ROISTART: Give an array of 3 numbers of the pixel coordinates of the
%           start of your region of interest, no need for the full four digits:
%           0020 -> 20. E.g. [21 30 150]
%       KL_DATA: Give the name of the matrix containing the data as given in
%           the Matlab Workspace.
%
%   => writeKnossosRoi( �E:\e_k0563\k0563_mag1', �100527_k0563_mag1�, [21 30 150], ans )
%
% WRITEKNOSSOSROI(KL_PARFOLDER, KL_FILEPREFIX, KL_ROISTART, KL_DATA, CLASST): %   
%   The function has the following arguments:
%       CLASST: paramter specifying a class type to save the data as eg.
%       'uint8' (standard) or 'single'
%

    if (nargin < 5)
        classT = 'uint8';        
    end
    if (nargin < 6)
        kl_filesuffix = '';        
    end
    if (nargin < 7)
        options = '';
    end
    % Calculate the cube's size in pixels and xyz-coordinates
    data_size = size( kl_data );
    data_size = [data_size repmat( 1,3 - ndims( kl_data ) )];
    kl_bbox = [kl_roiStart; kl_roiStart + data_size - 1]';
 
    kl_bbox_cubeind = [floor( ( kl_bbox(:,1) - 1 ) / 128 ) ceil( kl_bbox(:,2) / 128 ) - 1];

    % Read every cube touched with readKnossosCube, substitute the
    % overlapping parts and then write the whole cube with writeKnossosCube
    for kl_cx = kl_bbox_cubeind(1,1) : kl_bbox_cubeind(1,2)
        for kl_cy = kl_bbox_cubeind(2,1) : kl_bbox_cubeind(2,2)
            for kl_cz = kl_bbox_cubeind(3,1) : kl_bbox_cubeind(3,2)
                
                kl_thiscube_coords = [[kl_cx; kl_cy; kl_cz], [kl_cx; kl_cy; kl_cz] + 1] * 128;
                kl_thiscube_coords(:,1) = kl_thiscube_coords(:,1) + 1;

                kl_validbbox = [max( kl_thiscube_coords(:,1), kl_bbox(:,1) ),...
                    min( kl_thiscube_coords(:,2), kl_bbox(:,2) )];

                kl_validbbox_cube = kl_validbbox - repmat( kl_thiscube_coords(:,1), [1 2] ) + 1;
                kl_validbbox_roi = kl_validbbox - repmat( kl_bbox(:,1), [1 2] ) + 1;
                
                if strcmp(options,'noRead')
                    kl_cube = kl_data( kl_validbbox_roi(1,1) : kl_validbbox_roi(1,2),...
                    kl_validbbox_roi(2,1) : kl_validbbox_roi(2,2),...
                    kl_validbbox_roi(3,1) : kl_validbbox_roi(3,2) );
                else
                    kl_cube = readKnossosCube( kl_parfolder, kl_fileprefix, [kl_cx, kl_cy, kl_cz], [classT '=>' classT], kl_filesuffix);
                    kl_cube( kl_validbbox_cube(1,1) : kl_validbbox_cube(1,2),...
                        kl_validbbox_cube(2,1) : kl_validbbox_cube(2,2),...
                        kl_validbbox_cube(3,1) : kl_validbbox_cube(3,2) ) =...
                        kl_data( kl_validbbox_roi(1,1) : kl_validbbox_roi(1,2),...
                        kl_validbbox_roi(2,1) : kl_validbbox_roi(2,2),...
                        kl_validbbox_roi(3,1) : kl_validbbox_roi(3,2) );
                end
                
                writeKnossosCube( kl_parfolder, kl_fileprefix, [kl_cx, kl_cy, kl_cz], kl_cube, classT, kl_filesuffix, options);

%                 fprintf('.');
            end
        end
    end
end
