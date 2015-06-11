function err = randErrMaskGreaterZero( gT, seg, r, useMex, useP )

% RANDERR Calculate the rand error of a segmentation
%
%   The function has the following arguments:
%       GT: The ground truth segmentation (matrix).
%       SEG: The segmentation of which you want to calculate the metric
%           (matrix).
%       R: Euclidean distance, in which pairwise connection are supposed to
%           be considered. Can be either a scalar (max. distance) or a
%           vector of length 2 (min. distance, max. distance).
%       USEMEX: Binary variable, whether to use the quicker mex function
%           (only 64bit).
%       USEP: Binary variable, whether to use parallel loops.
%
    
    if nargin < 3
        r = 1;
    end
    if nargin < 4
        useMex = 1;
    end
    if nargin < 5
        useP = 0;
    end

    [ n1, m1, p1 ] = size( gT );
    [ n2, m2, p2 ] = size( seg );
    
    if n1 ~= n2 || m1 ~= m2 || p1 ~= p2
        fprintf( 'The segmentation and the ground truth need to be the same size!\n' );
        err = [];
        return;
    end
    
    gT = double( gT );
    seg = double( seg );
    
    nP = 4; % Number of workgroups
    
    if max( size( r ) ) == 1
        r1 = 0;
        r2 = r;
    elseif max( size( r ) ) == 2
        r1 = r( 1 );
        r2 = r( 2 );        
    else
        fprintf( 'Wrong size of input vector r!\n' );
    end
    
    % Use the appropriate function
    if useMex == 1
        if useP == 1
            % Parallelize by slicing the x-direction and keeping the others
            % constant.
            err1 = zeros( nP, 1 );
            N1 = zeros( nP, 1 );
            parfor i = 1 : nP
                if i < nP
                    % Beware indices start at 0
                    t1 = int32( [ floor( ( i - 1 ) * n1 / nP ), ...
                        floor( i * n1 / nP ) - 1 ] ); 
                    t2 = int32( [ 0, m1 ] );
                    t3 = int32( [ 0, p1 ] );            
            
                    [ err1( i ), N1( i ) ] = randRMexMaskGreaterZero( gT, seg, r1, r2, ...
                        t1, t2, t3 ); 
                else
                    % Beware indices start at 0
                    t1 = int32( [ ( i - 1 ) * n1 / nP, n1 ] ); 
                    t2 = int32( [ 0, m1 ] );
                    t3 = int32( [ 0, p1 ] ); 
                    
                    [ err1( i ), N1( i ) ] = randRMexMaskGreaterZero( gT, seg, r1, r2, ...
                        t1, t2, t3 ); 
                end
            end
            err = sum( err1 );
            N = sum( N1 );
        else
            % Beware indices start at 0
            t1 = int32( [ 0, n1 ] ); 
            t2 = int32( [ 0, m1 ] );
            t3 = int32( [ 0, p1 ] );            
            
            [ err, N ] = randRMexMaskGreaterZero( gT, seg, r1, r2, t1, t2, t3 );
        end            
    else
        if useP == 1
            % Parallelize by slicing the x-direction and keeping the others
            % constant.
            err1 = zeros( nP, 1 );
            N1 = zeros( nP, 1 );
            parfor i = 1 : nP
                if i < nP
                    % Beware indices start at 1
                    t1 = [ floor( ( i - 1 ) * n1 / nP ) + 1, ...
                        floor( i * n1 / nP ) - 1 ]; 
                    t2 = [ 1, m1 ];
                    t3 = [ 1, p1 ];            
            
                    [ err1( i ), N1( i ) ] = randR( gT, seg, r1, r2, ...
                        t1, t2, t3 ); 
                else
                    % Beware indices start at 0
                    t1 = [ ( i - 1 ) * n1 / nP + 1, n1 ]; 
                    t2 = [ 1, m1 ];
                    t3 = [ 1, p1 ]; 
                    
                    [ err1( i ), N1( i ) ] = randR( gT, seg, r1, r2, ...
                        t1, t2, t3 ); 
                end
            end
            err = sum( err1 );
            N = sum( N1 );
        else
            % Beware indices start at 1
            t1 = [ 1, n1 ]; 
            t2 = [ 1, m1 ];
            t3 = [ 1, p1 ];  
            
            [ err, N ] = randR( gT, seg, r1, r2, t1, t2, t3 );
        end            
    end


    % Normalize error
    err = err / N;    
    
    
  
%     if ~isempty( box )
%         conn = 0;
%         for i = 1 : n1
%             iCoord = [ max( 1, i - box( 1 ) ), min( n1, i + box( 1 ) ) ];
%             for j = 1 : m1
%                 jCoord = [ max( 1, j - box( 2 ) ), min( m1, j + box( 2 ) ) ];
%                 for k = 1 : k1
%                     kCoord = [ max( 1, k - box( 3 ) ), min( k1, k + box( 3 ) ) ];
%                     thisGT = gT( iCoord( 1 ) : iCoord( 2 ), jCoord( 1 ) : jCoord( 2 ), ...
%                         kCoord( 1 ) : kCoord( 2 ) );
%                     thisSeg = seg( iCoord( 1 ) : iCoord( 2 ), jCoord( 1 ) : jCoord( 2 ), ...
%                         kCoord( 1 ) : kCoord( 2 ) );
%                     
%                     thisGT( thisGT ~= gT( i, j, k ) ) = 0;
%                     thisSeg( thisSeg ~= seg( i, j, k ) ) = 0;
% 
%                     err = err + sum( sum( sum( abs( thisGT - thisSeg ) ) ) ) - 1;
%                     conn = conn + numel( thisSeg ) - 1;
%                 end
%             end
%         end
%         err = err / conn;
%         
%     else
%         N = n1 * m1 * k1;
%         gT = reshape( gT, N, 1 );
%         seg = reshape( seg, N, 1 );
%         
% %         for i = 1 : N
% %             thisGT = gT;
% %             thisSeg = seg;
% % 
% %             thisGT( thisGT ~= gT( i ) ) = 0;
% %             thisGT( i ) = 0;
% %             thisSeg( thisSeg ~= seg( i ) ) = 0;
% %             thisSeg( i ) = 0;
% % 
% %             err = err + sum( abs( thisGT - thisSeg ) );
% %         end
%         
%         %err = fullRandLim7( gT, seg, 1000000 ); % 904s 7.74s
%         err = fullRandLim9( gT, seg, 201^3 ); % 913s 7.68s
% 
%         %err = err / binomial( N, 2 );
%     end
end

