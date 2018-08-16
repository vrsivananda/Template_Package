function [hmarks, vmarks] = dex_load_marks( filename, wb )

%  [hmarks, vmarks] = dex_load_marks( filename, wb )
%
%  Given the Dex 'D' file denoted by filename, hunt through the Dex file
%  for all of the saccade-related marks that are stored there.  Each of the
%  return values, hmarks and vmarks, will be a matrix of trials (rows) by
%  trial time (columns, at whatever resolution the Rex and Dex files are
%  written at, usually 1000 Hz), and the saccade marks will be inserted in
%  this matrix at the appropriate times for the appropriate trials.  Thus
%  if trial 22 has an 'i' (for saccade start) at time 512 for the horizontal
%  eye trace, then hmarks( 22, 512 ) will be set to 'i'.  Times when no
%  signal occurs are set to 0.  All trials are padded with 0 to the length
%  of the longest trial.  Thus these matrices are quite large and very
%  sparse.
%
%  A more useful, and less insane representation of saccade onset and
%  offset times can be gotten by calling dex_find_saccades_from_marks with
%  the hmarks and vmarks values returned by dex_load_marks.
%
%  The second parameter, wb, is optional, but if given should be the handle
%  of a waitbar window (see waitbar).
%

if nargin<2
    wb = 0;
end;

hmarks = [];
vmarks = [];

fid = fopen( filename, 'r' );

trial = 0;
nhmarks = [0];
nvmarks = [0];
currsignal = '';

if fid == -1
    disp( 'Cannot open the file.' );
    return;
end;

wbc = 0;
if wb
    waitbar( wbc, wb, 'Importing saccade marks from DEX file...' );
end;

reading = (fid ~= -1 );

while reading
    line = fgetl( fid );
    if ~ischar( line )
        reading = 0;
    end;
    
    if wb 
        wbc = wbc + 0.0001;
        if wbc > 0.4 && wbc < 0.41
            waitbar( 0.2, wb, 'Still working on DEX marks...' );
        elseif wbc > 0.2 && wbc < 0.21
            waitbar( wbc, wb, 'Reading DEX files can take a while...' );
        elseif wbc < 0.2
            waitbar( wbc, wb ); 
        end;
    end;
    
    % parse each line here
    
    f = strfind( line, ' ' );
    if ~isempty( f )
        label = line( 1:f(1)-1 );
        if strcmp( label, 'TRIAL' )
            newtrial = str2num( line( f(1)+1:end ) );
            if trial
                hmarks = cat_variable_size_row( hmarks, nhmarks );
                vmarks = cat_variable_size_row( vmarks, nvmarks );
            end;
            
            for t = trial+1:newtrial-1
                hmarks = cat_variable_size_row( hmarks, [0] );
                vmarks = cat_variable_size_row( vmarks, [0] );                
            end;
            
            trial = newtrial;
            nhmarks = [0];
            nvmarks = [0];
        end;
        if strcmp( label, 'SIGNAL_LABEL' );
            currsignal = line( f(1)+1:end );
%             currsignal
        end;
        if strcmp( label, 'A' ) && numel( f ) > 2
            mark = line( f(1)+1:f(2)-1);
            pos = str2num( line( f(2)+1:f(3)-1 ) );

            if strcmp( currsignal, 'horiz_eye' )
                nhmarks( pos ) = mark;
%                 disp( mark );
            elseif strcmp( currsignal ,'vert_eye' )
                nvmarks( pos ) = mark;
%                 disp( mark );
            end;
        end;         
    
    end;
    
end;

fclose( fid );