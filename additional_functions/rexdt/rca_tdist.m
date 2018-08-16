function [ys] = rca_tdist( t, df )

        
        lastexpon = -1 * (df+1)/2;
        term2 = (1 + ((t.^2) ./ df) );
        
        term1numer = 0;
        term1denom = 0;
        if mod( df, 2 ) == 0 %even
            term1numer = prod( 3:2:(df-1) );
            term1denom = 2 * sqrt( df ) * prod(2:2:(df-2) );
        else
            term1numer = prod( 2:2:(df-1) );
            term1denom = pi * sqrt( df ) * prod( 3:2:(df-2) );
        end;

        ys = (term1numer/term1denom) .* (term2 .^ lastexpon);
