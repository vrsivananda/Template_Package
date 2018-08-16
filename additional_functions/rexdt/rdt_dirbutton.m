function [] = rdt_dirbutton

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_ecodes;
global rdt_etimes;
global rdt_includeaborted;

secondcode = rdt_ecodes( 2 );

   prompt={ 'Generate histograms for all dir trials.\nIgnore this line for now:',...
            'miliseconds before alignment time to gather spike data:',...
            'miliseconds after alignment time to gather spike data:',...
            'Bin width for histogram (leave blank for 20ms):',...
            'Initial sigma for density functions (blank for 5ms):',...
            'Type a 1 to display rasters and saccade velocities:', ...
            'Type a 1 to include BAD trials:' };
        
   name='DIR task analysis';
   %numlines=1;
   %defaultanswer={'20','hsv'};
 
   answer=inputdlg(prompt,name);
   if isempty( answer )
       return;
   end;
 
   for d=1:7
       if isempty( answer{d} )
           answerint(d) = 0;
       else
           answerint(d) = str2num( answer{d} );
       end;
   end;
       
%    aligncodes = answerint( 1 );
%    if aligncodes == 0
%        return;
%    end;
   aligncodes = 0;

   mstart = answerint( 2 );
   if mstart == 0
       mstart = 1000;
   elseif mstart < 0
       mstart = mstart * -1.0;        
   end;
   mstop = answerint( 3 );
   if mstop == 0
       mstop = 500;
   end;
   
   binwidth = answerint(4);
   if binwidth <= 0
       binwidth = 20;
   end;
   
   fsigma = answerint( 5 );
   if fsigma == 0
       fsigma = 5;
   end;

   includeext = answerint(6);
   includebad = answerint(7);
   
   rex_8dir_spike_display( rdt_filename, mstart, mstop, 6010, [], [], 7010, [1 0 1 0 1 1 includebad] );

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
%     