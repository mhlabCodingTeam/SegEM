function err = warpErr( gT, seg, analogue, useMex, useP )

% RANDERR Calculate the rand error of a (binary) segmentation
%
%   The function has the following arguments:
%       GT: The binary ground truth segmentation (3d matrix).
%       SEG: The segmentation of which you want to calculate the metric
%           (3d matrix).
%       ANALOGUE: Original 3d image, on which the segmentation was
%           performed. This is used for warping.
%       USEMEX: Binary variable, whether to use the quicker mex function
%           (only 64bit).
%       USEP: Binary variable, whether to use parallel loops.
%
    
    if nargin < 4
        useMex = 1;
    end

    if ~isfloat( gT )
        gT = double( gT );
    end
    if ~isfloat( seg )
        seg = double( seg );
    end
    if ~isfloat( analogue )
        analogue = double( analogue );
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
    [ n3, m3, k3 ] = size( analogue );
    
    if n1 ~= n2 || m1 ~= m2 || k1 ~= k2
        fprintf( 'The segmentation and the ground truth need to be the same size!\n' );
        err = [];
        return;
    end
    if n2 ~= n3 || m2 ~= m3 || k2 ~= k3
        fprintf( 'The segmentation and the analogue image need to be the same size!\n' );
        err = [];
        return;
    end
    
    % Main function
    if useMex == 1
        %warpSeg = warpMex( gT, analogue, useP );
        warpSeg = warpMexFull2( gT, analogue );
        %warpSeg = warpMexFullNoMask( gT, analogue );
    else
        warpSeg = warp( gT, analogue );
    end
    
    err = voxelErr( seg, warpSeg );
    
end

