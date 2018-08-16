function [am] = amplitude_fluctuation( signal )

%  Since this returns the mean (of the absolute value of the first
%  derivative), it is normalized to the length of the signal.

deriv = diff( signal );
absderiv = abs( deriv );

am = mean( absderiv );