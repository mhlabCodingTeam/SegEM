function err = voxelErr( gT, seg )

% VOXELERR Calculate the voxel error of a binary segmentation
%
%   The function has the following arguments:
%       GT: The ground truth segmentation (3d matrix).
%       SEG: The binary segmentation of which you want to calculate the 
%           metric (3d matrix).
%
    
    if ~isfloat( gT )
        gT = double( gT );
    end
    if ~isfloat( seg )
        seg = double( seg );
    end
    if max( max( max( seg ) ) ) > 1 || min( min( min( seg ) ) ) < 0
        fprintf( 'The segmentation is not binary!\n' );
        err = [];
        return;
    end
    if max( max( max( gT ) ) ) > 1 || min( min( min( gT ) ) ) < 0
        fprintf( 'The ground truth is not binary!\n' );
        err = [];
        return;
    end
    
    [ n1, m1, k1 ] = size( gT );
    [ n2, m2, k2 ] = size( seg );
    
    if n1 ~= n2 || m1 ~= m2 || k1 ~= k2
        fprintf( 'The segmentation and the ground truth need to be the same size!\n' );
        err = [];
        return;
    end
    
    % Count voxels, which have different values in gT and seg
    err = sum( sum( sum( abs( gT - seg ) ) ) );
    
    % Normalize to a value between 0...1
    err = err / ( n1 * m1 * k1 );
end

