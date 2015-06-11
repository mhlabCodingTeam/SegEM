% Calculate the comparison plot between segm1, segm2 and segm3

rMax =  2 : 0.5 : 12 ;
n = max( size( rMax ) );

kMax = 4;

err1 = zeros( n, kMax );
err2 = zeros( n, kMax );
err3 = zeros( n, kMax );

%parpool( kMax );
%delete( gcp );

% Calculate the rand error
parfor k = 1 : kMax
    for i = 1 : n
        if mod( i - k , kMax ) == 0
            fprintf( 'Currently at: i = %d \n', i );
            err1( i, k ) = randErr( gT, seg1, [ 0, rMax( i ) ], 1, 0 );
            err2( i, k ) = randErr( gT, seg2, [ 0, rMax( i ) ], 1, 0 );
            err3( i, k ) = randErr( gT, seg3, [ 0, rMax( i ) ], 1, 0 );
        end
    end
end

% Save the data, don't save the data from loadData.m
clear( 'classifier', 'em', 'gT', 'seg1', 'seg2', 'seg3', 'skel' );

folderName = '\Rand\';
fileName = 'data.mat';

if exist( [ pwd, folderName ], 'file' ) == 0
    mkdir( [ pwd, folderName ] );
    if exist( [ pwd, folderName, fileName ], 'file' ) == 0
        save( [ pwd, folderName, fileName ] );
    else
        fprintf( 'File already exists. Workspace has not been saved!\n' );
    end 
else
    if exist( [ pwd, folderName, fileName ], 'file' ) == 0
        save( [ pwd, folderName, fileName ] );
    else
        fprintf( 'File already exists. Workspace has not been saved!\n' );
    end 
end

err1 = sum( err1, 2 );
err2 = sum( err2, 2 );
err3 = sum( err3, 2 );

figure( 1 );
plot( rMax, err1, rMax, err2, rMax, err3 );
%xlim( [ 2, 12 ] );
ylim( [ 0, 1 ] );
grid on;
title( 'Rand Error' );
xlabel( 'Distance rMax' );
ylabel( 'Rand error' );
legend( 'segm1', 'segm2', 'segm3', 'Location', 'NorthWest' );

