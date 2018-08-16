function [meancount, meanrate, allcounts, allrates] = raster_epoch_mean( rasters, startindex, stopindex, srate )

sz = size( rasters );
rows = sz( 1 );
cols = sz( 2 );

meancount = 0;
meanrate = 0;
allcounts = [];
allrates = [];

if startindex < 1 || stopindex > cols || rows < 1 || startindex >= stopindex
    disp( 'raster_epoch_mean:  input parameters are wonky,' );
    return;
end;

time = (stopindex - startindex) + 1;

for t=1:rows
    allcounts(t) = sum( rasters(t, startindex:stopindex ) );
    allrates(t) = allcounts(t) * srate / time;
end;

meancount = mean(allcounts);
meanrate = mean(allrates);

