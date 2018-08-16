function [randrast] = randomize_rasters( raster, mindistance, withreplacetrials, withreplacespikes, maxtrials )

if nargin < 2
    mindistance = 1;
end;
if nargin < 3
    withreplacetrials = 0;
end;
if nargin < 4
    withreplacespikes = 0;
end;
if nargin < 5
    maxtrials = -1;
end;



sz = size( raster );
numtrials = maxtrials;
if numtrials < 1
    numtrials = sz(1);
end;
randrast = zeros( sz );
rasterline = zeros( 1, sz(2) );
for i = 1:numtrials
    rline = i;
    if withreplacetrials
        rline = ceil( rand() * sz(1) );
    end;
    if rline > sz(1)
        rline = mod( rline, sz(1)) + 1;
    end;
    rasterline = raster( rline, : );
    if mindistance==1 && ~withreplacespikes
        randrast( i, : ) = rasterline( randperm( sz(2) ) );
    else
        f = [];
        if withreplacespikes
            wrs = 1;
            fi = 1;

            while wrs <= sz(2)
                rli = ceil( rand() * sz(2) );
                f(fi) = rli;
                if (rasterline(rli) > 0 )
                    wrs = wrs + mindistance;
                    fi=fi+1;
                else
                    wrs = wrs + 1;
                end;
            end;
        else
            f = find( rasterline ~= 0 );
        end;
        num = length( f );
        permrow = rasterline .* 0;
        numidx = 1;
        newf = [];
        % check here for the unresolvable condition.
        maxpossible = floor( sz(2) / mindistance );
        minpossible = floor( sz(2) / ((2*mindistance) - 1) );
        if (num > minpossible && ~withreplacespikes )
            s1 = sprintf( 'randomize_rasters:  Cannot guarantee that %d numbers can be put', num );
            s2 = sprintf( '  randomly into an array of size %d with a minimum distance of %d.', sz(2), mindistance );
            disp( s1 );
            disp( s2 );
        else
            while numidx <= length( f )
                idx = ceil( rand() * sz( 2 ) );
                allgood = 1;
                for j = 1:numidx-1
                    if abs( idx - newf(j) ) < mindistance
                        allgood = 0;
                    end;
                end;
                if allgood
                    newf( numidx ) = idx;
                    randrast( i, idx ) = rasterline( f( numidx ) );
                    numidx = numidx + 1;
                end;
            end;
        end;
    end;
end;
