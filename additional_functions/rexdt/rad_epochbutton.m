function [] = rad_epochbutton

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_ecodes;
global rdt_etimes;
global rdt_includeaborted;

global rad_fh;
global rad_taskcheck1handle;
global rad_taskcheck2handle;
global rad_taskcheck3handle;
global rad_taskcheck4handle;

global rad_aligncombohandle;
global rad_preedithandle;
global rad_postedithandle;
global rad_binedithandle;
global rad_sigmaedithandle;

global rad_rastercheckhandle;
global rad_spikedenscheckhandle;
global rad_probdenscheckhandle;
global rad_eyecheckhandle;
global rad_summarycheckhandle;
global rad_badcheckhandle;

NUMEPOCHS = 5;
SRATE = 1000;

epochalignbase = [6600 6600 6600 7200 7400];
epochstart = [-100 101 301 1 51]; 
epochstop = [-1 300 500 50 250];

task(1) = (get( rad_taskcheck1handle, 'Value' ) == get( rad_taskcheck1handle, 'Max' ));
task(2) = (get( rad_taskcheck2handle, 'Value' ) == get( rad_taskcheck2handle, 'Max' ));
task(3) = (get( rad_taskcheck3handle, 'Value' ) == get( rad_taskcheck3handle, 'Max' ));
task(4) = (get( rad_taskcheck4handle, 'Value' ) == get( rad_taskcheck4handle, 'Max' ));
includebad = (get( rad_badcheckhandle, 'Value' ) == get( rad_badcheckhandle, 'Max' ));

numtasksrequested = sum( task( 1:4 ) );

if ~numtasksrequested
    disp( 'No task types selected.' );
    return;
end;

treq = 1;
for t = 1:4
    if task(t)
        taskrequested( treq ) = t-1;
        treq =treq + 1;
    end;
end;

ealigns = [];
estarts = [];
estops = [];

wb = waitbar( 0, 'Calculating spike counts and rates...' );

for e = 1:NUMEPOCHS
    sc = [];
    sr = [];
    for t = 1:numtasksrequested
        waitbar( (e * t) / (NUMEPOCHS*numtasksrequested), wb );
        
        %  Generate 1 raster for each direction, and for each of the 
        %  selected task types (types are not combined).
    
        for d = 1:8
            ealigndir = epochalignbase(e) + (d-1) + (taskrequested( t ) * 10);
            [raster, aidx, eyeh, eyev, eyevel] = rex_rasters_trialtype( rdt_filename, 1, ealigndir, [],[], ealigndir, includebad);
            if isempty( raster )  || sum( sum( raster ) ) == 0
                s = ['rad_epochbutton:  No raster could be generated for alignment codes: ', num2str( ealigndir' ) ];
                disp( s );
            else
                sz = size( raster );
                if (aidx + epochstart(e) < 1) || ( aidx + epochstop(e) > sz(2) )
                    disp ( 'rad_epochbutton: requested epochs span beyond the raster generated.' );
                else
    
                    %  Hooray, we have the raster for direction d, task t.  Get epoch numbers.
    
                    [meancount, meanrate, allcounts, allrates] = ...
                        raster_epoch_mean( raster, aidx+epochstart(e), aidx+epochstop(e), SRATE );
                    spkcount(e,t,d) = meancount;
                    spkrate(e,t,d) = meanrate;
                    sc( d, t ) = meancount;
                    sr( d, t ) = meanrate;
                end;
            end;
        end;
    end;

    s = sprintf( 'time %d to %d relative to code %d', epochstart(e), epochstop(e), epochalignbase(e) );
    fh = figure( 'Name', s );
    subplot( 2, 1, 1 );
    bar( sc );
    title( 'mean spike count' );
    subplot( 2, 1, 2 );
    bar( sr );
    title( 'mean spike rate' );
end;

close( wb );

    
    
    


                
