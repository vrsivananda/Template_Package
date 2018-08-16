function [segments] = segment_matrix( matrix, segsize )

sz = size( matrix );
segments = [];

if sz(2) < segsize
    disp( 'segment_matrix:  matrix too small for the segment size requested' );
    return;
end;

numsegs = floor(sz( 2 ) / segsize);
segments = zeros( sz(1), numsegs );
for row = 1:sz( 1 )
    for segment= 1:numsegs
        segments( row, segment ) = mean( matrix( row, (((segment-1) * segsize) + 1) : (segment * segsize) ) );
    end;
end;