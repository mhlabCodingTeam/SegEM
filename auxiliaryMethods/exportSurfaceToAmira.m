function exportSurfaceToAmira( mss_isfs, mss_outputfile, kl_surfColors, kl_xyzpermutation, kn_enforceOwn )

% EXPORTSURFACETOAMIRA: Export an isosurface created by Matlab to Amira in
%   the Amira Mesh format.
%   
%   The function has the following arguments:
%       MSS_ISFS: Give the name of a cell array containing the
%           isosurfaces, one cell per isosurface, e.g. iso in the Matlab workspace.
%       MSS_OUTPUTFILE: Give the full path of the file in which you want to
%           write the data, e.g. 'E:\surfaces.am'
%       KL_SURFCOLORS: Optional! Give an array containing the colors of the
%           isosurfaces in the RGB format, e.g. for two cells [0 0 1; 0 1 0]
%       KL_XYZPERMUTATION: Optional! Give the permutation of dimensions of the stack,
%           e.g. swapping y and z [1 3 2]
%       KN_ENFORCEOWN: Optional! Give 1 to enforce, that the file belongs
%           to Moritz Helmstaedter, BMO-Lab. 0 is standard. Works only on
%           Linux based operating systems!
%       
%   => exportSurfaceToAmira( iso, 'E:\surfaces.am', [0 0 1; 0 1 0], [1 3 2], 1 )
%

    % If no permutation is given, use the identity permutation.
    if nargin < 4
        kl_xyzpermutation = [1 2 3];
    end
    
    % If no value is given for kn_enforeOwn, set to zero.
    if nargin < 5 
        kn_enforceOwn = 0;
    end
    
    % Get the number of isosurfaces in the cell array.
    mss_nIsfs = size( mss_isfs, 2 ); 

    % Create the file, if it already exists, delete the content.
    fid = fopen( mss_outputfile, 'w' ); 
    
    % Write into the file. The Amira Mash format has an ASCII head setting
    % the basic features.
    fprintf( fid, '# HyperSurface ASCII\n\n\n' ); 
    fprintf( fid, '\tMaterials { \n' );
    mss_nIsfs_real = 0;
    
    % For preallocation.
    mss_vertOffsets = zeros(mss_nIsfs + 1 , 1);
    
    % Go over all the isosurfaces
    for mss_c = 1 : mss_nIsfs 
        
        % Check whet.her the cell array contains a structure array named
        % vertices
        if isfield( mss_isfs{mss_c}, 'vertices' ) 
            
            % Count the number of isosurfaces, as the size of the cell
            % array and the number of isosurfaces does not have to be the same. 
            mss_nIsfs_real = mss_nIsfs_real + 1; 
            
            % Check if the color of the isosurface is given, if not get a random color. 
            % || indicates a logical "or".
            if nargin < 3 || isempty( kl_surfColors ) 
                kl_thisColor = rand(1,3);
                
            % If a color is given, use it.
            else 
                kl_thisColor = kl_surfColors( mss_c, : );
            end
            
            % Write the color of the isosurface into the file.
            fprintf( fid, '\t\t{\n\t\tcolor %.2f %.2f %.2f,\n\t\tName \"%s\" }\n', kl_thisColor, sprintf( 'col%d', mss_c ) ); 
            
            % Save the size of the isosurface in an array.
            mss_vertOffsets( mss_c + 1 ) = size( mss_isfs{mss_c}.vertices, 1 ); 
        end
    end
        
    fprintf( fid, '\n\t}' );
    
    % Write the whole size into the file.
    fprintf( fid, '\n\tVertices %d\n', sum( mss_vertOffsets ) ); 
    
    % Go over all the isosurfaces
    for mss_c = 1 : mss_nIsfs 
        
        % Check whether the cell array contains a structure array named
        % vertices.
        if isfield( mss_isfs{mss_c}, 'vertices' ) && ~isempty(mss_isfs{mss_c}.vertices)
            
            % Write the data from .vertices into the file according to the
            % permutation.
            fprintf( fid, '\t\t %.4f %.4f %.4f\n', mss_isfs{mss_c}.vertices( :, kl_xyzpermutation )' ); 
            fprintf( 1, '.' );
        end
    end
    
    fprintf( fid, '\n\tPatches %d\n', mss_nIsfs_real );
    
    % Go over all the isosurfaces
    for mss_c = 1 : mss_nIsfs
        
        % Check whether the cell array contains a structure array named
        % vertices.
        if isfield( mss_isfs{mss_c}, 'vertices' )
            
            % Write the data from .faces into the file.
            fprintf( fid, '\n{\tInnerRegion %s\n\t\tOuterRegion %s\n', sprintf( 'col%d', mss_c ), sprintf( 'col%d', mss_c ) );
            fprintf( fid, '\t\tTriangles %d\n', size( mss_isfs{mss_c}.faces, 1 ) );
            fprintf( fid, '\t\t %d %d %d\n', mss_isfs{mss_c}.faces( :, 1 : 3 )' + sum( mss_vertOffsets( 1 : mss_c ) ) );
            fprintf( fid, '\n}' );
            %fprintf( 1, '.' );
        end
    end

    % End the writing and close the file.
    fprintf( fid, '\n' );
    fclose( fid );
    
    % If enforceOwn is one, then enforce, that the file belongs to Moritz
    % Helmstaedter.
    if kn_enforceOwn == 1 
        system( sprintf( 'chown mhelmsta:bmo %s', mss_outputfile ) );
    end

end
