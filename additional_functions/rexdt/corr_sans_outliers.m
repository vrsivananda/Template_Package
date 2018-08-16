function [r, prob] = corr_sans_outliers( signal1, signal2, includerange1, includerange2 );

if nargin < 3
    includerange1 = [];
end;
if nargin < 4
    includerange2 = [];
end;

std1 = std( signal1 ) * 2;
std2 = std( signal2 ) * 2;

mean1 = mean( signal1 );
mean2 = mean( signal2 );

diff1 = abs( mean1 - signal1 );
diff2 = abs( mean2 - signal2 );

fout1 = find( diff1 > std1 );
fout2 = find( diff2 > std2 );
exclude = [fout1;fout2];

if ~isempty( includerange1 )
    flo1 = find( signal1 < includerange1(1) );
    fhi1 = find( signal1 > includerange1(2) );
    exclude = [exclude; flo1; fhi1];
end;
if ~isempty( includerange2 )
    flo2 = find( signal2 < includerange2(1) );
    fhi2 = find( signal2 > includerange2(2) );
    exclude = [exclude; flo2; fhi2];
end;

% exclude

news1 = [];
news2 = [];
next = 0;
for d = 1:length( signal1 )
    f = find( exclude == d );
    if isempty( f )
        next = next + 1;
        news1( next ) = signal1( d );
        news2( next ) = signal2( d );
    end;
end;

% signal1
% news1
% signal2
% news2
% figure();
% plot( news1, news2, 'o' );

if isempty( news1 ) || isempty( news2 )
    r = 0;
    prob = 1;
else
    [r, prob] = corr( news1', news2' );
end;

% pause;