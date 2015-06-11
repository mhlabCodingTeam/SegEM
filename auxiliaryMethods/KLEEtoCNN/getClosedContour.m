function mgc_contCl = getClosedContour( mgc_cont )

% GETCLOSEDCONTOUR: Get a closed contour from any given KLEE contour
%   
%   The function has the following argument:
%       MGC_CONT: Give a two-dimensional array of a 2D KLEE contour, e.g.
%           one of the arrays in contours{} in a KLEE tracing. 
%       
%   => getClosedContour( KLEE_savedTracing.contours{1} )
%

    % Initialize an array and sum up the three columns of mgc_cont into one
    mgc_contCl = [];
    mgc_sum = sum( mgc_cont, 2 );
 
    % Only proceed if mgc_cont is not empty. Now the function determines,
    % which elements to copy from mgc_cont into mgc_contCl.
    if ~isempty( mgc_cont )
        
        % If the first element is not a number (nan), then start with the
        % second element.
        if isnan( mgc_sum(1) )
            mgc_indxR(1) = 2;
        else            
            mgc_indxR(1) = 1;
        end
        
        % If the last element is not a number, then end with the second
        % last element.
        if isnan( mgc_sum( end ) )
            mgc_indxR(2) = size( mgc_cont, 1 ) - 1;
        else
            mgc_indxR(2) = size( mgc_cont, 1 );
        end
        
        % Now copy all the columns, from element mgc_indxR(1) till
        % mgc_indxR(2) and then again mgc_indxR(1) into mgc_contCl. The
        % element mgc_indxR(1) is copied twice to close the contour line.
        mgc_contCl = mgc_cont( [mgc_indxR(1) : mgc_indxR(2), mgc_indxR(1) ], : );
    end
end