function [eucd] =  rex_sdfdist( basesdf, comparesdf, binsize )

if size( basesdf ) ~= size( comparesdf )
    disp( 'rex_sdfdist:  the baseline and comparison vectors do not have the same size.  And they should.' );
    eucd = 0;
    return;
elseif isempty( basesdf ) || isempty( comparesdf ) || (binsize < 1)
    disp( 'rex_sdfdist:  either one of the spike densities is empty, or binsize < 1.  Fix it.' );
end;

len = length( basesdf );
numbins = floor(len / binsize);

for d =(1:numbins)
    start = ((d - 1) * binsize) + 1;
    stop = (d * binsize);
    if (stop > len)
        stop = len;
    end;
    basebin( d ) = mean( basesdf( start:stop ) );
    comparebin( d ) = mean( basesdf( start:stop ) );
end;

eucd = sum((basebin - comparebin).^2).^0.5;

