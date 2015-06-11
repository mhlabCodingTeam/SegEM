function [ err, corrErr, errTriple ] = fullRand( gT, seg )

% FULLRAND Variations of rand à la Hubert & Arabie (1985)
%   Detailed explanation goes here

gTint = int32( gT );
segint = int32( seg );

uniqueGT = int32( unique( gT ) );
unique1 = int32( unique( seg ) );

cT = randContingencyTable( gTint, segint, uniqueGT, unique1 );

n = numel( gT );
bico = 0.5 * n * ( n - 1 );

% Seg 1
%type1 = 0.5 * sum( sum( cT .* ( cT - 1 ) ) );
%type2 = 0.5 * ( n^2 + sum( sum( cT.^2 ) ) - ...
%    ( sum( sum( cT, 2 ).^2 ) + sum( sum( cT, 1 ).^2 ) ) );
type3 = 0.5 * ( sum( sum( cT, 1 ).^2 ) - sum( sum( cT.^2 ) ) );
type4 = 0.5 * ( sum( sum( cT, 2 ).^2 ) - sum( sum( cT.^2 ) ) );

err = type3 + type4;
err = err / bico;

corrInd = ( sum( sum( 0.5 * ( cT .* ( cT - 1 ) ) ) ) - ...
    sum( 0.5 * ( sum( cT, 2 ) .* ( sum( cT, 2 ) - 1 ) ) ) * ...
    sum( 0.5 * ( sum( cT, 1 ) .* ( sum( cT, 1 ) - 1 ) ) ) / bico ) / ...
    ( 0.5 * sum( 0.5 * ( sum( cT, 2 ) .* ( sum( cT, 2 ) - 1 ) ) ) + ...
    0.5 * sum( 0.5 * ( sum( cT, 1 ) .* ( sum( cT, 1 ) - 1 ) ) ) - ...
    sum( 0.5 * ( sum( cT, 2 ) .* ( sum( cT, 2 ) - 1 ) ) ) * ...
    sum( 0.5 * ( sum( cT, 1 ) .* ( sum( cT, 1 ) - 1 ) ) ) / bico );

if corrInd < 0
    corrInd = 0;
end
corrErr = 1 - corrInd;

% val = 0;
% for i = 1 : size( cT, 1 )
%     valI = sum( cT( i, : ) ) - 1;
%     for j = 1 : size( cT, 2 )
%         val = val + cT( i, j ) * valI * ( sum( cT( :, j ) ) - 1 );
%     end
% end
% 
% triple1 = 2 * ( ( n - 1 ) * sum( sum( cT1 .* ( cT1 - 1 ) ) ) - val );
% con_dis1 = triple1;

% Choose normalization (3)
%triple1 = triple1 / ( 2 * sum( sum( cT1, 2 ) .* ( sum( cT1, 2 ) - 1 ) .* ...
%    ( n - sum( cT1, 2 ) ) ) );

val1 = 0;
val2 = 0;
for i = 1 : size( cT, 1 )
    valI = sum( cT( i, : ) );
    for j = 1 : size( cT, 2 )
        valJ = sum( cT( :, j ) );
        val1 = val1 + cT( i, j ) * ( cT( i, j ) - 1 ) * ( n - valI - valJ + cT( i, j ) );
        val2 = val2 + cT( i, j ) * ( valI - cT( i, j ) ) * ( valJ - cT( i, j ) );
    end
end

condis = 2 * ( val1 + val2 );

dis = 2 * val2;
% Normalization (2)
errTriple = dis / condis;

%if triple1 < 0
%    triple1 = 0;
%end
%errTriple1 = 1 - triple1;

end

