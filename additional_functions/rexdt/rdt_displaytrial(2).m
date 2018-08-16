function [] = rdt_displaytrial()

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_ecodes;
global rdt_etimes;
global rdt_includeaborted;



    [ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, rdt_badtrial ] = rex_trial(rdt_filename, rdt_trialnumber);%, rdt_includeaborted);
    rdt_ecodes = ecodeout;
    rdt_etimes = etimeout;
    
    hcolor = 'b';
    vcolor = 'r';
    scolor = 'g';
    if isempty(h) || isempty(ecodeout)
        disp( 'Something wrong with trial, no data.' );
    else
        secondcode = ecodeout(2);
        s = sprintf( '%s trial #%d, code is %d.', rdt_filename, rdt_trialnumber, secondcode );
        if rdt_badtrial
            s= cat( 2, s, '  BAD TRIAL' );
            hcolor = 'k';
            vcolor = 'k';
            scolor = 'y';
        end;

%         edhv = sqrt( (h .* h) + (v .* v ) );
%         dedhv = diff( edhv );
        [sstarts, sends] = rex_trial_saccade_times( rdt_filename, rdt_trialnumber);%, rdt_includeaborted );
        gunk = h .* 0;
        if ~isempty( sstarts )
            for d = 1:length( sstarts )
                if sstarts(d) == 0 || sends( d ) == 0
                 d
                 sstarts( d )
                 sends( d )
                else
                gunk( sstarts(d):sends(d) ) = 20;
                end;
            end;
        end;
        



        lasttime = max( etimeout );
        last = max( lasttime, length( h ) );
        codetrain = zeros( 1, last );
        ettemp = etimeout;
        ettemp( find( ettemp < 1 ) ) = 1;
        codetrain( ettemp ) = ecodeout;
        
        train = [];
        subplot( 3, 1, 2 );
        plot( 0 );
        if ~isempty( spk )
            train = rex_spk2raster( spk, 1, length( h ) );
        end;

        wide = max( [length( train ) length( codetrain ) length( h )] );
        
        
        figure( rdt_fh );

        subplot( 3, 1, 1 );
        plot( h, hcolor );
        title( s );
        hold on;
        plot( v, vcolor );
        plot( gunk, scolor );
        hold off;
        ax = axis();
        ax(2) = wide;
        axis( ax );
        last = 0;

        subplot( 3, 1, 3 );
        bar( codetrain );
        ax = axis();
        ax(2) = wide;
        axis( ax );
        title( 'CODES' );

        if ~isempty( train )
            subplot( 3, 1, 2 );
            bar( train );
            ax = axis();
            ax(2) = wide;
            axis( ax );
           title( 'Spike data' );
        end;
                
%             nrl = 1+spk{1} - etimeout(1);
%             if ~isempty(nrl)
%                 last = max( nrl( end ), length( h ) );
%                 train = zeros( 1, last );
%                 train( nrl ) = 1;

        s=sprintf( 'The length of the eye signal is %d, and the maximum spike time is %d.', length( h ), last );        
        if rdt_badtrial
            s= cat( 2, s, '  This trial was aborted or deleted.' );
        end;
%        disp( s );
    end;
        