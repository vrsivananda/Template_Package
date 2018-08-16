

for d = 1:1000
    faketrain = zeros( 1, 1000 );
    fakerate = d*1;
    idxs = ceil( rand( 1,fakerate ) * 1000 );
    faketrain( idxs ) = 1;
    
    sdf = spike_density( faketrain, 5);
    sdfmean(d) = mean(sdf);
    srate(d) = sum( faketrain );
end;

ratio = sdfmean ./ srate ;
disp( sum( sdfmean ) / sum( srate/1000 ) );

figure;
hold on;
plot( sdfmean, 'g' );
plot( srate, 'r' );
plot( ratio, 'k' );