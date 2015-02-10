function copyCubeSubset( kl_bbox_cubeIDs, kl_sourceDir, kl_targetDir )

% COPYCUBESUBSET: Copy subcubes of raw EM data from an existing directory to another.
%   
%   The function has the following arguments:
%       KL_BBOX_CUBEIDS: Give a 2x3-Matrix containing the xyz-coordinates
%           of the subcube, e.g. [ 0 1; 0 1; 0 1 ]
%       KL_SOURCEDIR: Give the root directory of the EM data as a string,
%           e.g. 'E:\e_k0563\k0563_mag1\'
%       KL_TARGETDIR: Give the target directory of the files as a
%           string, e.g. 'E:\e_k0563\k0563_mag1_subcube\'
%       
%   => copyCubeSubset( [ 0 1; 0 1; 0 1 ], 'E:\e_k0563\k0563_mag1\', 'E:\e_k0563\k0563_mag1_subcube\' )
%

    % Create the target directory
    if ~exist(kl_targetDir, 'dir')
    	mkdir(kl_targetDir);
    end
    
    % Copy the file "knossos.conf" to the target directory
    copyfile(fullfile( kl_sourceDir, 'knossos.conf' ), kl_targetDir );
        
    % Now successively create directories and copy the cubes
    for kl_x = kl_bbox_cubeIDs( 1, 1 ) : kl_bbox_cubeIDs( 1, 2 )
        % Create all the "x"-directories
	if ~exist(fullfile( kl_targetDir, sprintf( 'x%04.0f', kl_x)), 'dir' ) 
		mkdir(fullfile( kl_targetDir, sprintf( 'x%04.0f', kl_x)));
	end    
        for kl_y = kl_bbox_cubeIDs( 2, 1 ) : kl_bbox_cubeIDs( 2, 2 )
            % Create all the "y"-directories
	    if ~exist(fullfile( kl_targetDir, sprintf( 'x%04.0f', kl_x ), sprintf( 'y%04.0f', kl_y )), 'dir');
            	mkdir(fullfile( kl_targetDir, sprintf( 'x%04.0f', kl_x ), sprintf( 'y%04.0f', kl_y )));
            end
            for kl_z = kl_bbox_cubeIDs( 3, 1 ) : kl_bbox_cubeIDs( 3, 2 )
                % Create all the "z"-directories
		if ~exist(fullfile( kl_targetDir, sprintf( 'x%04.0f', kl_x ), sprintf( 'y%04.0f', kl_y ), sprintf( 'z%04.0f', kl_z )), 'dir');
                	mkdir(fullfile( kl_targetDir, sprintf( 'x%04.0f', kl_x ), sprintf( 'y%04.0f', kl_y ), sprintf( 'z%04.0f', kl_z )));
                end
                % Copy the .raw file into the target directory
                copyfile(fullfile( kl_sourceDir, sprintf( 'x%04.0f', kl_x ), ...
                    sprintf( 'y%04.0f', kl_y ), sprintf( 'z%04.0f', kl_z ), '*.*' ), fullfile( kl_targetDir, ... 
                    sprintf( 'x%04.0f', kl_x ), sprintf( 'y%04.0f', kl_y ), sprintf( 'z%04.0f', kl_z ) ) );
            end
        end
    end
