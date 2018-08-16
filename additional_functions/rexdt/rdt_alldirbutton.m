function [] = rdt_alldirbutton

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


secondcode = rdt_ecodes( 2 );

rad_fh = figure;
set( rad_fh, 'Position', [100 300 400 500] );
taskstr = 'self timed|memory guided|visually guided|audio guided';
alignstr = ['trial start (6000)|' ...
            'fixation on (6200)|' ...
            'initial fixation (6400)|' ...
            'task stimulus on (6600)|' ...
            'task stimulus off (6800)|' ...
            'wait for saccade (target on) (7000)|' ...
            'saccade onset (7200)|' ...
            'saccade done (7400)|' ...
            'post saccade target display (7600)|' ...
            'ENABLECD (1035)|' ...
            'reward start (1030)|' ...
            'external trigger on (5999)|' ...
            'external trigger off (5998)'];
        
%taskcombohandle = uicontrol( 'Parent', rad_fh, 'Style', 'popupmenu', 'String', taskstr, 'Position', [10 270 200 20] );
uicontrol( 'Parent', rad_fh, 'Style', 'text', 'String', 'Select task types to compile', 'Position', [10 470 160, 20] );
rad_taskcheck1handle = uicontrol( 'Parent', rad_fh, 'Style', 'checkbox', 'String', 'self timed (600x)', 'Position', [170 470 200 20] );
rad_taskcheck2handle = uicontrol( 'Parent', rad_fh, 'Style', 'checkbox', 'String', 'memory guided (601x)', 'Position', [170 450 200 20] );
rad_taskcheck3handle = uicontrol( 'Parent', rad_fh, 'Style', 'checkbox', 'String', 'visually guided (602x)', 'Position', [170 430 200 20] );
rad_taskcheck4handle = uicontrol( 'Parent', rad_fh, 'Style', 'checkbox', 'String', 'audio guided (603x)', 'Position', [170 410 200 20] );

uicontrol( 'Parent', rad_fh, 'Style', 'text', 'String', 'Select an alignment code', 'Position', [10 370 160, 20] );
rad_aligncombohandle = uicontrol( 'Parent', rad_fh, 'Style', 'popupmenu', 'String', alignstr, 'Position', [170 370 200 20] );

uicontrol( 'Parent', rad_fh, 'Style', 'text', 'String', 'ms before alignment', 'Position', [10 320 120, 20] );
rad_preedithandle = uicontrol( 'Parent', rad_fh, 'Style', 'edit', 'String', '1000', 'Position', [10 305 100 20] );
uicontrol( 'Parent', rad_fh, 'Style', 'text', 'String', 'ms after alignment', 'Position', [10 270 120, 20] );
rad_postedithandle = uicontrol( 'Parent', rad_fh, 'Style', 'edit', 'String', '500', 'Position', [10 255 100 20] );
uicontrol( 'Parent', rad_fh, 'Style', 'text', 'String', 'bin width for histograms', 'Position', [250 320 120, 20] );
rad_binedithandle = uicontrol( 'Parent', rad_fh, 'Style', 'edit', 'String', '5', 'Position', [250 305 100 20] );
uicontrol( 'Parent', rad_fh, 'Style', 'text', 'String', 'Initial sigma for density functions', 'Position', [250 270 120, 20] );
rad_sigmaedithandle = uicontrol( 'Parent', rad_fh, 'Style', 'edit', 'String', '5', 'Position', [250 255 100 20] );

rad_rastercheckhandle = uicontrol( 'Parent', rad_fh, 'Style', 'checkbox', 'String', 'show rasters', 'Position', [10 210 200 20] );
rad_spikedenscheckhandle = uicontrol( 'Parent', rad_fh, 'Style', 'checkbox', 'String', 'show spike density function', 'Position', [10 190 200 20] );
rad_probdenscheckhandle = uicontrol( 'Parent', rad_fh, 'Style', 'checkbox', 'String', 'show probability density function', 'Position', [10 170 200 20] );
rad_eyecheckhandle = uicontrol( 'Parent', rad_fh, 'Style', 'checkbox', 'String', 'show eye velocity trace', 'Position', [10 150 200 20] );
rad_summarycheckhandle = uicontrol( 'Parent', rad_fh, 'Style', 'checkbox', 'String', 'generate summary figure', 'Position', [10 130 200 20] );
rad_badcheckhandle = uicontrol( 'Parent', rad_fh, 'Style', 'checkbox', 'String', 'include bad trials', 'Position', [10 110 200 20] );

histobhandle = uicontrol( 'Parent', rad_fh, 'Style', 'pushbutton', 'String', 'Compile', 'Position', [10 10 80 20] );
set( histobhandle, 'Callback', 'rad_histobutton' );
extrabhandle = uicontrol( 'Parent', rad_fh, 'Style', 'pushbutton', 'String', 'Epochs', 'Position', [90 10 80 20] );
set( extrabhandle, 'Callback', 'rad_epochbutton' );
closebhandle = uicontrol( 'Parent', rad_fh, 'Style', 'pushbutton', 'String', 'Close', 'Position', [200 10 80 20] );
set( closebhandle, 'Callback', 'global rad_fh; close( rad_fh )' );

%  Some default values

set( rad_aligncombohandle, 'Value', 7 );

% 
%    prompt={ 'Generate histograms for all dir trials.\nIgnore this line for now:',...
%             'miliseconds before alignment time to gather spike data:',...
%             'miliseconds after alignment time to gather spike data:',...
%             'Bin width for histogram (leave blank for 20ms):',...
%             'Initial sigma for density functions (blank for 5ms):',...
%             'Type a 1 to display rasters and saccade velocities:', ...
%             'Type a 1 to include BAD trials:' };
%         
%    name='DIR task analysis';
%    %numlines=1;
%    %defaultanswer={'20','hsv'};
%  
%    answer=inputdlg(prompt,name);
%    if isempty( answer )
%        return;
%    end;
%  
%    for d=1:7
%        if isempty( answer{d} )
%            answerint(d) = 0;
%        else
%            answerint(d) = str2num( answer{d} );
%        end;
%    end;
%        
% %    aligncodes = answerint( 1 );
% %    if aligncodes == 0
% %        return;
% %    end;
%    aligncodes = 0;
% 
%    mstart = answerint( 2 );
%    if mstart == 0
%        mstart = 1000;
%    elseif mstart < 0
%        mstart = mstart * -1.0;        
%    end;
%    mstop = answerint( 3 );
%    if mstop == 0
%        mstop = 500;
%    end;
%    
%    binwidth = answerint(4);
%    if binwidth <= 0
%        binwidth = 20;
%    end;
%    
%    fsigma = answerint( 5 );
%    if fsigma == 0
%        fsigma = 5;
%    end;
% 
%    includeext = answerint(6);
%    includebad = answerint(7);
%    
%    dirrast = [];
%    dirhist = [];
%    dirsdf = [];
%    dirpdf = [];
%    diraidx = [];
%    
%    wb = waitbar( 0.1, 'Compiling trials...' );
%     
%    for d = 0:7
%        acode = 7010+d;
%        tcode = 6010+d;
%        s = sprintf( 'Calculating trials with code %d, aligned to %d...', tcode, acode );
%        waitbar( 0.1 + (d * 0.12), wb, s );
%        [r,h,aidx,eyeh, eyev, eyevel] = rex_rasters_trialtype( rdt_filename, binwidth, tcode, [],[], acode, includebad);
%        if isempty( r )  || sum( sum( r ) ) == 0
%            s = sprintf( 'No raster could be generated for alignment code %d.', acode );
%            disp( s );
%            sumall = zeros( 1, mstart+mstop );
%            h = zeros( 1, floor((mstart+mstop)/binwidth) );
%            sdf = sumall;
%            pdf = sumall;
%            aidx = mstart;
%            alignindex = aidx;
%            start = 0;
%        else
%             start = aidx - mstart;
%             stop = aidx + mstop;
%             if start < 1
%                 start = 1;
%             end;
%             if stop > length( r )
%                 stop = length( r );
%             end;
%             starth = ceil( start / binwidth );
%             stoph = floor( stop / binwidth );
%     
%             sumall = merge_raster( r( :, start:stop ) );
%             sdf = spike_density( sumall, fsigma );
%             pdf = probability_density( sumall, fsigma );
%             
%             alignindex = aidx - start;
%             
%             if includeext
%                 fx = figure;
%                 set( fx, 'name', [rdt_filename ' code:' num2str( acode )] );
%                 subplot( 3, 1, 1 );
%                 imagesc( r(:, start:stop ) );
%                 colormap( 1- gray);
%                 title( 'spike raster, aligned to saccade onset' );
%                 subplot( 3, 1, 2 );
%                 plot( sdf );
%                 aline = zeros( 1, length( sdf ) );
%                 aline( alignindex ) = max( sdf );
%                 hold on;
%                 plot( aline, 'r' );
%                 hold off;
%                 axis( 'tight' );
%                 title( 'spike density function ' );
%                 subplot( 3, 1, 3 );
%                 sz = size( eyevel );
%                 if sz(2) >= stop
%                     plot( eyevel( :, start:stop)' );
%                     hold on;
%                     meanvel = mean( eyevel( :, start:stop ) );
%                     plot( meanvel, 'k-', 'LineWidth', 2 );
%                     hold off;
%                 else
%                     s = sprintf( 'size(1) is %d and size(2) is %d for the eye velocity trace for the %d trials.', sz(1), sz(2), tcode );
%                     disp(s);
%                     s = sprintf( 'start is %d and stop is %d.\n', start, stop );
%                     disp( s );
%                     pause;
%                 end;
%                 axis( 'tight' );
%                 title( 'eye velocity' );
%             end;
%                 
%                 
%        end;
% 
%        dirrast = cat_variable_size_row( dirrast, sumall );
%        dirhist = cat_variable_size_row( dirhist, h );
%        dirsdf = cat_variable_size_row( dirsdf, sdf );
%        dirpdf = cat_variable_size_row( dirpdf, pdf );
%        diraidx(d+1) = alignindex;
%        
%        % do we need to adjust based on alignment index here?
%        % see align_rows_on_indices.
%    end;
%    
% maxsdf = max( max( dirsdf ) );
% 
% spn = [1 2 4 6 8 7 5 3];
% ttl = {'up 7010' 'up right 7011' 'right 7012' 'down right 7013' 'down 7014' 'down left 7015' 'left 7016' 'up left 7017'};
% fh = figure;
% set( fh, 'name', rdt_filename );
% 
% 
% for d = 1:8
%     aline = zeros( 1, length( dirsdf( d, : ) ) );
%     aline( diraidx(d) ) = maxsdf;
%     subplot( 4, 2, spn(d) );
%     plot( dirsdf( d, : ) );
%     axis tight;
%     ax = axis;
%     ax(4) = maxsdf;
%     axis( ax );
%     hold on;
%     plot( aline, 'r' );
%     title( ttl(d ) );
% end;
% 
% 
% 
%     
%     close( wb );
%     
    