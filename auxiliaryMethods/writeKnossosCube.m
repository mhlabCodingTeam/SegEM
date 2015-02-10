function writeKnossosCube( kl_parfolder, kl_fileprefix, kl_cubeCoord, kl_cube, classT, kl_filesuffix, options )

% WRITEKNOSSOSCUBE: Write from Matlab into raw data 
%   
%   The function has the following arguments:
%       KL_PARFOLDER: Give the root directory where you want the file to be
%           saved as a string, e.g. 'E:\e_k0563\k0563_mag1\'
%       KL_FILEPREFIX: Give the name with which you want the file to be saved without
%           the coordinates or the ending as a string, e.g. '100527_k0563_mag1'
%       KL_CUBECOORD: Give an array of 3 numbers of the xyz-coordinates of
%           the location of the cube, no need for the full four digits:
%           0020 -> 20. E.g. [21 30 150]
%       KL_CUBE: Give the name of the 128x128x128 matrix containing the data as
%           given in the Matlab Workspace.
%       
%   => writeKnossosCube( �E:\e_k0563\k0563_mag1', �100527_k0563_mag1�, [21 30 150], ans )
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

    if strcmp(options, 'check0cube')
        if sum(kl_cube(:)) == 0
            return;
        end
    end
    
    % Building the full filename
    kl_fullfile = fullfile( kl_parfolder, sprintf( 'x%04.0f', kl_cubeCoord(1) ),...
        sprintf( 'y%04.0f', kl_cubeCoord(2) ), sprintf( 'z%04.0f', kl_cubeCoord(3) ),...
        sprintf( '%s_x%04.0f_y%04.0f_z%04.0f%s.raw', kl_fileprefix, kl_cubeCoord, kl_filesuffix) );

    % Building the name of the directory, where the file is to be saved
    fullfolder = fullfile( kl_parfolder, sprintf( 'x%04.0f', kl_cubeCoord(1) ),...
        sprintf( 'y%04.0f', kl_cubeCoord(2) ), sprintf( 'z%04.0f', kl_cubeCoord(3) ) );

    % If the directory does not exist, build it
    if ~exist( fullfolder, 'dir' )
        mkdir( fullfolder );
    end

    % If the file exsits and the option 'mergePedantic' is passed check
    % whether we are not canceling data
    if( exist( kl_fullfile, 'file' ) && strcmp(options,'mergePendantic'))
        fid = -1;
        while fid < 0
            fid = fopen( kl_fullfile );
            pause(2);
        end    
        kl_cube_before = fread( fid, 'uint8' );
        kl_cube_before = reshape( kl_cube_before, [128 128 128] );
        kl_cube_before = cast(kl_cube_before, class(kl_cube));
        temp = (kl_cube_before ~= 0) .* (kl_cube ~= 0);
        if sum(temp(:)) == 0
            kl_cube = kl_cube + kl_cube_before;
            fwrite( fid, reshape( cast(kl_cube, classT), 1, [] ), classT );
            fclose( fid );
        else
            fclose( fid );
            error('Error: You are trying to replace existing values');
        end
    else
         % Create the file and write in it
        fid = fopen( kl_fullfile, 'w+' );
        fwrite( fid, reshape( cast(kl_cube, classT), 1, [] ), classT );
        fclose( fid );       
    end
    
end
