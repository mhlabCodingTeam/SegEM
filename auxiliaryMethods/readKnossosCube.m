function kl_cube = readKnossosCube( kl_parfolder, kl_fileprefix, kl_cubeCoord, classT, kl_filesuffix, ending,cubesize)

% READKNOSSOSCUBE: Read raw data from EM into Matlab
%
%   The function has the following arguments:
%       KL_PARFOLDER: Give the root directory of the data you want to read as a
%           string, e.g. 'E:\e_k0563\k0563_mag1\'
%       KL_FILEPREFIX: Give the name of the specific file you want to read without
%           the coordinates or the ending as a string, e.g. '100527_k0563_mag1'
%       KL_CUBECOORD: Give an array of 3 numbers of the xyz-coordinates as
%           given in the file name, no need for the full four digits: 0020 ->
%           20. E.g. [21 30 150]
%       CLASST: Optional! Standard version is unsigned int with 8 bits. For the
%           precision of the values.
%
%   => readKnossosCube( �E:\e_k0563\k_0563_mag1', �100527_k0563_mag1�, [21 30 150], �uint8� )
%

if( nargin < 4 )
    classT = 'uint8=>uint8';
end
if( nargin < 5 )
    kl_filesuffix = '';
end
if( nargin < 6 )
    if( strcmp( classT, 'uint8=>uint8' ) )
        ending = 'raw';
    else
        ending = 'mat';
    end
end
if (nargin<7)
    cubesize=[128 128 128];
end
if numel(cubesize)==1
    cubesize=repmat(cubesize,1,3);
end

% Building the full filename
kl_fullfile = fullfile( kl_parfolder, sprintf( 'x%04.0f', kl_cubeCoord(1) ),...
    sprintf( 'y%04.0f', kl_cubeCoord(2) ), sprintf( 'z%04.0f', kl_cubeCoord(3) ),...
    sprintf( ['%s_x%04.0f_y%04.0f_z%04.0f%s.' ending], kl_fileprefix, kl_cubeCoord, kl_filesuffix ) );

% If this file exists, load it into Matlab, else fill the matrix with zeros
if( exist( kl_fullfile, 'file' ) )
    if( strcmp( ending, 'raw' ) )
        fid = fopen( kl_fullfile );
        kl_cube = fread( fid, classT);
        kl_cube = reshape( kl_cube, cubesize);
        fclose( fid );
    else
        load( kl_fullfile );
        if ~exist( 'kl_cube', 'var' )
            kl_cube = kl_stack;
        end
    end
else
    classT2=bsxfun(@eq,classT,'>');
    classT2=classT(find(classT2)+1:end);
    kl_cube = zeros( cubesize, classT2 );
end
end