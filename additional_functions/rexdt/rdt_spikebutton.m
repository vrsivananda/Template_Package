function [] = rdt_spikebutton

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_includeaborted;


    wbh = waitbar( 0, 'Generating spike analysis...' );
    
    foundspikedata = 0;

    [ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, rdt_badtrial ] = rex_trial(rdt_filename, rdt_trialnumber);
    
    if isempty(h) || isempty(ecodeout)
        disp( 'Something wrong with trial, no data.' );
    else
        secondcode = ecodeout(2);
        s = sprintf( 'Spike data, %s trial #%d, code is %d.', rdt_filename, rdt_trialnumber, secondcode );
        if rdt_badtrial
            s= cat( 2, s, '  ABORTED.' );
        end;
    
        waitbar( 0.1, wbh );
        
        train = [];
        if ~isempty( spk )
            nrl = 1+spk{1} - etimeout(1);  %%% Why is this here?  Is this wrong?
            if ~isempty(nrl)
                foundspikedata = 1;
                last = max( nrl( end ), length( h ) );
                train = zeros( 1, last );
                train( nrl ) = 1;
                waitbar( 0.25, wbh );
                sdf = spike_density( train, 20 );
                waitbar( 0.6, wbh );
                pdf = probability_density( train, 20 );
                waitbar( 0.9, wbh );

                figure();
                subplot( 3, 1, 1 );
                bar( train );
                title( s );
                subplot( 3, 1, 2 );
                plot( sdf );
                title( 'Spike density function' );
                subplot( 3, 1, 3 );
                plot( pdf );
                title( 'Probability density function (adaptive)' );
            end;
        end;    
    end;
    
    close( wbh );
    
    if ~foundspikedata
        uiwait(msgbox('No spike data are available for this trial.', 'No spike data', 'error', 'modal'));
    end;