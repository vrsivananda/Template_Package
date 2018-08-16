function [] = rds_displaytrialsaccade()

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_ecodes;
global rdt_etimes;
global rdt_includeaborted;
global rds_fh;



[ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, rdt_badtrial ] = rex_trial(rdt_filename, rdt_trialnumber);%, rdt_includeaborted);
 if isempty(h) || isempty(ecodeout)
     disp( 'Something wrong with trial, no data.' );
     return;
 end;

 
rdt_ecodes = ecodeout;
rdt_etimes = etimeout;
    
hcolor = 'b';
vcolor = 'r';
scolor = 'g';

secondcode = ecodeout(2);
s = sprintf( '%s trial #%d, code is %d.', rdt_filename, rdt_trialnumber, secondcode );
if rdt_badtrial
    s= cat( 2, s, '  BAD TRIAL' );
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
        

        figure( rds_fh );
        plot( h, hcolor );
        title( s );
        hold on;
        plot( v, vcolor );
        plot( gunk, scolor );
        hold off;
        last = 0;
