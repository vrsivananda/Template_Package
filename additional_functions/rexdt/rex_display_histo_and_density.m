function[fh] = rex_display_histo_and_density( raster, histo, sdf, pdf, alignmentindex, aligncodes )

  
    aidx = alignmentindex;    
    start = aidx - 999;
    stop = aidx + 500;
    if start < 1
        start = 1;
    end;
    if stop > length( raster )
        stop = length( raster );
    end;
% start = 1;
% stop = length( raster );
    
    sz = size( raster );
    binwidth = ceil( length( raster) / length( histo ) );
    starth = ceil( start / binwidth );
    stoph = floor( stop / binwidth );

    invgray = 1.0 - gray;
    fh = figure();
    subplot( 4,1, 1 );
    fat = fat_raster( raster, 3 );
    imagesc( fat(:,start:stop) );
    %imagesc( fat );
    colormap( invgray );
    ax1 = axis();
    s0 = sprintf( '%d ', aligncodes );
    s1 = sprintf( 'Spike raster, n = %d trials, aligned to %s, at index %d', sz( 1 ), s0, aidx+1-start );
    title( s1 );
    subplot( 4, 1, 2 );
    bar( histo(starth:stoph), 'k' );
    title( 'spike histogram' );
    ax2 = axis();
    ax2(2) = ceil( ax1(2) / binwidth );
    axis( ax2 );
    subplot( 4, 1, 3 );
    plot( sdf(start:stop) );
    title( 'spike density function ' );
    ax3 = axis();
    ax3(2) = ax1(2);
    axis( ax3 );
    subplot( 4,1, 4 );
    plot( pdf( start:stop ) );
    title( 'probability density function (adaptive)' );
    ax4 = axis();
    ax4(2) = ax1(2);
    axis( ax4 );
    