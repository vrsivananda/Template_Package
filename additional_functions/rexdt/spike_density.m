function [allsdf, gksigma] = spike_density( train, fixedsigma )

sz = size( train );
allsdf = zeros( sz );

for row = 1:sz(1)
    numdata = sz(2);
    halflen = ceil( numdata / 2 );
    k = -halflen:halflen;
    gek2s2 = exp( -1 * (k .* k ) / (fixedsigma * fixedsigma ) );
    gdenom = sqrt( 2 * pi * fixedsigma * fixedsigma );
    gksigma = (1 / gdenom) * gek2s2;
    sdfconv = conv( train, gksigma );
    center = ceil( length( sdfconv ) / 2 );
    sdf = sdfconv( center - halflen:(center+halflen-1) );

    if length( sdf ) > sz(2)
        sdf = sdf( 1:sz(2) );
    end;
    allsdf (row,:) = sdf;
end;

%  Not sure why this is, but the sdf is always related to the actual spike
%  rate by a constant, 0.705 regardless of sigma.

allsdf = (allsdf .* 1000) ./ 0.705;
