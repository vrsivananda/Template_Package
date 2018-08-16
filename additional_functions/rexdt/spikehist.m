function spikes = spikehist( rasters, binwidth )

%  rasters should be a two-dimensional matrix, each row of which is a signal raster,
%  i.e., 1s where spikes occur in the data.

if binwidth == 1
    spikes = sum( rasters );
else
    sz = size( rasters );
    if sz(1) == 1
        rows = 1;
        cols = find( rasters );
        colsrange = length( cols );
    else
        [rows, cols] = find( rasters );
        %  cols now has the time points of all spikes in all rows.
        colsrange = size( cols );
    end;
    
    timerange = size( rasters );
    %numbins = ( timerange(2) / binwidth ) + 1;
    numbins = ceil( timerange(2) / binwidth );
    spikes = zeros( size(1:numbins) );
    
    for i = 1:colsrange(1)
        idx = ceil( cols( i ) / binwidth );
        spikes( idx ) = spikes( idx ) + 1;     
    end;
end;