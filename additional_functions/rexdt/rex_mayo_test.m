

   rexname = 'Nebp33n2t1';  % This will look for 'Nebp33n2t1.mat' 

   EVCODE = 6990;       %  Get data from trials with this code
   PREWINDOW = 250;     %  Time prior to saccade to get spikes
   POSTWINDOW = 250;    %  Time post saccade onset to get spikes
   
   allrasters = []; 
   allh = [];
   allv = [];
   allvel = [];
   rex_load_processed( rexname );  % Will convert from A and E if not found
   trial = rex_first_trial( rexname );
   if trial > 0
      islast = 0;
      while ~islast
          %  Get every tidbit of data about this trial.
          
          [ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, badtrial] = rex_trial(rexname, trial);
          [sacstarts, sacends] = rex_trial_saccade_times( rexname, trial );
          numsacs = length( sacstarts );
          
          %  Find when EVCODE happens in the code list.  Use whatever test
          %  logic is appropriate.
          
          fevent = find( ecodeout == EVCODE );
          if ~isempty( fevent )
              timeevent = etimeout( fevent(1) );
              
              %  find the first saccade whose start time is after the time
              %  of the event we found (EVCODEs).  fsac might have many
              %  entries, i.e. many saccades that happen after EVCODE.  We
              %  want only the first.
              
              fsac = find( sacstarts > timeevent );
              if isempty( fsac )
                  s = sprintf( 'trial %d had no saccades post EVCODE.', trial );
                    disp( s );
              end;
              if ~isempty( fsac )
                  timesac = sacstarts( fsac(1) );
                  
                  % Get the spike data for the time period we want around
                  % the saccade onset time.
                  
                  if ~isempty( spk )
                     [raster, last] = rex_spk2raster( spk, 1, length( h ) );
                     trialraster = raster( timesac - PREWINDOW: timesac+POSTWINDOW );
                     allrasters = cat( 1, allrasters, trialraster );
                  end;
                  
                  % Get the eye movement data for the same period.
                  % For velocity, the horizontal and vertical velocities
                  % are the 1st derivatives.  For overall velocity, use the
                  % pythagorean theorum on the component velocities.
                  
                  horiz = h( timesac- PREWINDOW:timesac+POSTWINDOW );
                  vert = v( timesac-PREWINDOW:timesac+POSTWINDOW );
                  dh = diff( horiz );
                  dv = diff( vert );
                  velocity = sqrt( (dh .* dh) + (dv .* dv) );
                  
                  % Compile them all in matrices.
                  
                  allh = cat( 1, allh, horiz );
                  allv = cat( 1, allv, vert );
                  allvel = cat( 1, allvel, velocity );
                 
              end;  % if ~isempty( fsac )
          end;  % if ~isempty( fevent )

          %  Get the next good trial, if there is one.
          
          [trial, islast] = rex_next_trial( rexname, trial );
          
      end;  % while ~islast
   end;  % if trial > 0
   
   %  Summate all the rasters for PETH-type things
   sumall = merge_raster( allrasters );
   %  Calculating spike density
   sdf = spike_density( sumall, 5 );
   %  Calculating probability density
   pdf = probability_density( sumall, 5 );

   figure(3);
   subplot( 3, 1, 1 );
   imagesc( allrasters );
   colormap( 1-gray );
   subplot( 3, 1, 2 );
   plot( sdf );
   axis tight;
   subplot( 3, 1, 3 );
   plot( pdf );
   axis tight;
   
   figure(4);
   subplot( 3, 1, 1 );
   plot( allh', 'b' );
   axis tight;
   subplot( 3, 1, 2 );
   axis tight;
   plot( allv', 'r' );
   axis tight;
   subplot( 3, 1, 3 );
   plot( allvel' );
   