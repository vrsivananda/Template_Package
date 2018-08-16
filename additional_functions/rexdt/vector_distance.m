function [distance] = vector_distance( v1, v2, normalizebydimensions )

    if nargin < 3
        normalizebydimensions = 0;
    end;
    
    distance = 0;
    if length( v1 ) ~= length( v2 )
        return;
    end;
    
    len = length( v1 );
    for i = 1:len
        sq(i) = (v1(i) - v2(i)) ^2;
    end;
    
    sumsquares = sum( sq );
    distance = sqrt( sumsquares );
    
    if normalizebydimensions
        distance = distance / len;
    end;