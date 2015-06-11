gT1 = gT;
gT1( gT1 > 0 ) = 1;

% threshold = 0.5;   
% thisBinary = ( classifier > threshold );
% thisBinary = double( thisBinary );
% err = warpErr( gT1, thisBinary, classifier, 1, 0 );
% 
% fprintf( 'Warp error with threshold %d is: %d\n', threshold, err );

% threshold = 0.1 : 0.1 : 0.9;
% n = max( size( threshold ) );
% 
% err = zeros( 1, n );
% 
% for i = 1 : n
%     thisBinary = ( classifier > threshold( i ) );
%     thisBinary = double( thisBinary );
%     err( i ) = warpErr( gT1, thisBinary, classifier, 1, 0 );
% end
% 
% figure( 1 );
% plot( threshold, err );
% grid on;
% title( 'Warping Error' );
% xlabel( 'Threshold' );
% ylabel( 'Warping error' );

m = 6;
p = 3;
n = m * p;
err = zeros( 1, n );
err1 = zeros( 1, p );
err2 = zeros( 1, p );
err3 = zeros( 1, p );
err4 = zeros( 1, p );
err5 = zeros( 1, p );
err6 = zeros( 1, p );
threshold = 0.05 : 0.05 : 0.90;

parfor i = 1 : p    
    thisBinary = double( classifier > threshold( i ) );
    err1( i ) = warpErr( gT1, thisBinary, classifier, 1, 0 );    
end
fprintf( 'Done with #1\n' );
parfor i = 1 : p    
    thisBinary = double( classifier > threshold( i + 1 * p ) );
    err2( i ) = warpErr( gT1, thisBinary, classifier, 1, 0 );    
end
fprintf( 'Done with #2\n' );
parfor i = 1 : p    
    thisBinary = double( classifier > threshold( i + 2 * p ) );
    err3( i ) = warpErr( gT1, thisBinary, classifier, 1, 0 );
end
fprintf( 'Done with #3\n' );
parfor i = 1 : p    
    thisBinary = double( classifier > threshold( i + 3 * p ) );
    err4( i ) = warpErr( gT1, thisBinary, classifier, 1, 0 );
end
fprintf( 'Done with #4\n' );
parfor i = 1 : p    
    thisBinary = double( classifier > threshold( i + 4 * p ) );
    err5( i ) = warpErr( gT1, thisBinary, classifier, 1, 0 );
end
fprintf( 'Done with #5\n' );
parfor i = 1 : p    
    thisBinary = double( classifier > threshold( i + 5 * p ) );
    err6( i ) = warpErr( gT1, thisBinary, classifier, 1, 0 );
end
fprintf( 'Done with #6\n' );

for i = 1 : 6
    err( 1 : 3 ) = err1;
    err( 4 : 6 ) = err2;
    err( 7 : 9 ) = err3;
    err( 10 : 12 ) = err4;
    err( 13 : 15 ) = err5;
    err( 16 : 18 ) = err6;
end

figure( 1 );
plot( threshold, err );
grid on;
ylim([0,1]);
title( 'Warping Error' );
xlabel( 'Threshold' );
ylabel( 'Warping error' );
