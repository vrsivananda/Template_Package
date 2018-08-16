function [zval, p] = rca_ztest( a, b, accuracy )

    if nargin < 3
        accuracy = 0;
    end;
    
    sta = std( a );
    mna = mean( a );
    mnb = mean( b );
    
    zval = (mnb - mna) / sta;
    az = abs( zval );
    x = abs( mnb - mna);
    p = 1.0;
    
    %  Calc area under curve from z on out.
    
    if az < 0.01
        p = 0.5;
        return;
    end;
    
    if az < 0.02
        p = 0.4960;
        return;
    end;
    
% for test=0:0.05:4
% z = test;
% sta = 1;
    
    if accuracy <= 0
        if az<0.05
            accuracy = 200;
        elseif az<0.2
            accuracy = 100;
        elseif az<0.5
            accuracy = 50;
        else 
            accuracy = 30;
        end;
    end;
    

    if accuracy > 1000
        accuracy = 1000;
        disp( 'rca_ttest2p: accuracy clipped at 1000 (5th parameter).');
    end;

    %  I think that one way to speed this up would be to use z (or az
    %  really) instead of x, and set v = 1.  In that case, v drops out
    %  everywhere, but anyway I think it amounts to the same thing.
    
    dx = x / (accuracy * accuracy);
    intervals = x:dx:(x * accuracy);
    ys = [];

    v = sta*sta;
    epart = exp( -1 * ( intervals.^ 2) / (2 * v ));
    ys = 1/sqrt( 2 * pi * v) .* epart;
    p = sum( ys ) .* dx;
% disp( sprintf( 'z=%f    p=%f', z, p ) );
% end;
