function [all] = merge_rasters( rasters, onemax )

if nargin < 2
    onemax = 0;
end;

sz = size( rasters );
if sz(1) <2
    all = rasters;
else
    all = sum( rasters );
end;

if onemax
    f = find( all > 1 );
    all( f ) = 1;
end;