function [c,t] = rex_display_codes( name )

[c,t] = rex_ecodes( name );

i1001 = find( c == 1001 );
i112 = find( c == -112 );

r1001 = c .* 0;
r112 = c .* 0;

r1001( i1001 ) = 10000;
r112( i112 ) = 9000;

figure
bar( c, 'k' );
hold on;
bar( r1001, 'b' );
bar( r112, 'r' );
hold off;

title( 'Trial start (1001) in blue, analog code (-112) in red' );
