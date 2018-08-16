function [pdf, gksigma] = probability_density( train, fixedsigma )

numdata = length( train );
halflen = ceil( numdata / 2 );
k = -halflen:halflen;
gek2s2 = exp( -1 * (k .* k ) / (fixedsigma * fixedsigma ) );
gdenom = sqrt( 2 * pi * fixedsigma * fixedsigma );
gksigma = (1 / gdenom) * gek2s2;
pilotconv = conv( train, gksigma );
center = ceil( length( pilotconv ) / 2 );
pilot = pilotconv( center - halflen:(center+halflen-1) );

if length( pilot ) > length( train )
    pilot = pilot( 1:length( train ) );
end;

% figure(1);
% subplot( 3, 1, 1 );
% plot( train );
% subplot( 3, 1, 2 );
% plot( gksigma );
% subplot( 3, 1, 3 );
% plot( pilot );

%  The log will fail wherever pilot is 0, so set those places to the
%  smallest non-zero value we find in the whole thing.

f = find( pilot>0 );
pmin = min( pilot( f ) );
nonzeropilot = pilot;
nonzeropilot( find( pilot == 0 ) ) = pmin;
lnpilot = log( nonzeropilot );
meanpilot = exp( sum( lnpilot ) / numdata );
bandwidthfactor = sqrt( nonzeropilot ./ meanpilot );

for k = 1:numdata
    fg = [];
    adjustsigma = fixedsigma ./ bandwidthfactor;
    kmi = k-1:-1:k-numdata;

    gek2s2 = exp( -1 .* (kmi .* kmi ) ./ (adjustsigma .* adjustsigma ) );
    gdenom = sqrt( 2 .* pi .* adjustsigma .* adjustsigma );
    gksigma = (1 ./ gdenom) .* gek2s2;
    fg = pilot .* gksigma;
    
%     for i = 1:numdata
%         %kmi = k - i;
%         %adjustsigma = fixedsigma / bandwidthfactor( i );
%         gek2s2 = exp( -1 * (kmi * kmi ) / (adjustsigma * adjustsigma ) );
%         gdenom = sqrt( 2 * pi * adjustsigma * adjustsigma );
%         gksigma = (1 / gdenom) * gek2s2;
%         fg( i ) = pilot( i ) * gksigma;
%     end;
    m( k ) = sum( fg ) / numdata;
end;

pdf = m;
if length( pdf ) > length( train )
    pdf = pdf( 1:length( train ) );
end;



