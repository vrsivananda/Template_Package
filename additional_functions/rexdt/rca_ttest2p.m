function [p] = rca_ttest2p( tobs, stdev, num, accuracy )

    %  Approximation of area under the curve (under the t-distribution), that
    %  corresponds to num-1 degrees of freedom, from tobs to infinity.

    if nargin < 4
        accuracy = 0;
    end;
    
    USEGAMMA = 0;
    USENORMALFORHIGHDF = 0;
    
    p = 1.0;    
    z = tobs;
    
    if z < 0.01
        p = 0.5;
        return;
    end;
    
    if z < 0.02
        p = 0.4960;
        return;
    end;
    
    if accuracy <= 0
        if z<0.05
            accuracy = 200;
        elseif z<0.2
            accuracy = 100;
        elseif z<0.5
            accuracy = 50;
        else 
            accuracy = 30;
        end;
    end;
    

    if accuracy > 1000
        accuracy = 1000;
        disp( 'rca_ttest2p: accuracy clipped at 1000 (5th parameter).');
    end;

    dz = z / (accuracy * accuracy);
    intervals = z:dz:(z * accuracy);
    ys = [];
    df = num-1;
    
    
    if ( df > 100 && USENORMALFORHIGHDF )

        % Normal distribution, approximated beyond df > 30, they say.
        
        v = stdev*stdev;
        epart = exp( -1 * ( intervals.^ 2) / (2 * v ));
        ys = 1/sqrt( 2 * pi * v) .* epart;
    elseif USEGAMMA
        
        % Actual t-distribution.  Neither's probably faster than the other.
        
        lastexpon = -1 * (df+1)/2;
        term2 = (1 + ((intervals.^2) ./ df) );
        term1numer = gamma( (df + 1) / 2 );
        term1denom = sqrt( df * pi ) * gamma( df / 2 );
        ys = (term1numer/term1denom) .* (term2 .^ lastexpon);
    else
        lastexpon = -1 * (df+1)/2;
        term2 = (1 + ((intervals.^2) ./ df) );
        
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

    end;
    
    p = sum( ys ) .* dz;
        
    
    

    