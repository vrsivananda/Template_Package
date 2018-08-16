function [tobs, p] = rca_ttest( a1, a2, paired, tails, accuracy )

    if nargin < 5
        accuracy = 0;
    end;
    
    tvals01 = [63.657 9.925 5.841 4.604 4.032 3.707 3.499 3.355 3.250 3.169 3.106 3.055 3.012 2.977 2.947 2.921 ...
        2.898 2.878 2.861 2.845 2.831 2.819 2.807 2.797 2.787 2.779 2.771 2.763 2.756 2.750 2.704 2.660 2.617 2.576];
    
    len1 = length(a1);
    len2 = length(a2);
    p = 1.0;
    tobs = 0;
    
    if ( len1 ~= len2 && paired )
       disp( 'rca_ttest: A paired t-test was requested, but the vector lengths were unequal.' );
       return;
    end;
    
    if (paired)
        bigD = a1 - a2;
        %sumD = sum( bigD );
        meanD = mean( bigD );
        stdD = std( bigD );
        
        tobs = abs( meanD / (stdD / sqrt( len1 ) ) );
        
        %df = len1-1;

        p = rca_ttest2p( tobs, stdD, len1, accuracy );
        if tails > 1
            p = p * 2;
        end;
    else
        disp( 'rca_ttest:  Sorry, but non-paired t-tests have not been implemented yet. ' );
    end;