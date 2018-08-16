function [] = rex()

% REX data functions
% 
% The following is a list of Matlab functions that can be used to convert,
% manipulate, edit, and display data produced by the REX software from the 
% Laboratory of Sensorimotor Research (ftp://lsr-ftp.nei.nih.gov).  A good
% starting point is to enter the command 'rexdt' (see below), and select a
% set of Rex data to convert and display.  Most routines have their own
% help topic (for example, type 'help rex_trial' for more information).
% 
% 
% Data retrieval functions
% 
% rex_load_processed � Load a set of trials from a converted (processed) 
%     Rex/Matlab file into memory, for use with the data retrieval functions.  
%     (This does not need to be explicitly called.  The data retrieval 
%     functions will load the requested data into memory if they are not 
%     present, and will also attempt a conversion from the original Rex A 
%     and E files (analog and event files) if the converted Matlab file 
%     cannot be found.  See also rex_process and rex_save.)
%  
% rex_trial - given a data file and a trial number, return arrays of 
%     information for eye movement, neural data, and codes.
% 
% num_rex_trials - How many trials are in a converted (processed) rex data 
%     file (the converted matlab file).
% 
% rex_first_trial � Return either the number of the first trial, or the 
%     first good trial (the first not marked as BAD or aborted) in a 
%     converted rex data file.
% 
% rex_next_trial � Given a trial number, return the number of either the 
%     next, or the next good trial, in the converted rex data file.
% 
% rex_prev_trial � Given a trial number, return the number of the previous, 
%     or the closest preceding good trial, in the converted rex data file.
% 
% rex_is_bad_trial � Is a particular trial marked as BAD (either during 
%     processing from the original Rex A and E file, or later by editing).
% 
% rex_make_bad_trial, rex_make_good_trial � mark a trial as BAD, or 
%     remove the BAD status, respectively.
%
% rex_trial_saccade_times - return saccade data for the requested trial as
%     two lists, one for start times, and and for end times.
% 
% rex_all_saccades - finds all saccades in all trials.  Returns a list of all 
%     saccade directions, and a list of all saccade amplitudes.
%
% rex_get_saccade - given a trial number and a saccade number n, returns
%     the eye movement traces and corresponding velocity for the nth
%     saccade, for a time window specified around the saccade start time.
%
% rex_erasesaccades � remove all saccade times from a specific trial.
% 
% rex_addsaccade � Given a start and end time, add these to lists of start 
%     and end times of saccades for a trial.
% 
% rex_save � Save modified data back into the converted (processed) 
%     Rex/Matlab file.  See also rex_load_processed and rex_process.
% 
% 
% User interface functions
%
% rexdt - by itself, presents a file selection dialog for selecting a Rex
%     data file.  It will load a previously-converted .mat file, or it will
%     make one by converting Rex 'A' and 'E' (analog and event) files.
%     Then it calls rex_display_trials.
% 
% rex_display_trials - presents user interface to display all trials in a 
%     converted Rex data file, including saccades, codes, and neural data.  
%     Allows marking of trials as BAD or not, and editing of saccade times.
% 
% rex_display_saccades � presents a user interface that finds saccades in 
%     all trials, regardless of time, and builds spike histograms based on 
%     size and direction.
% 
% rex_display_codes - displays all codes for a data file on a graph.
% 
% rex_rasters_trialtype - given codes to search for, generate spike rasters 
%     for those trials that match.  Can use �any of�, �all of�, and �none of� 
%     criteria when searching for matching trials, and will allow the 
%     inclusion or exclusion of BAD trials.
% 
% rex_spike2raster - convert spikes from rex_trial and such into rasters.
%  
% rex_saccade_spike_histo - given a set of saccade criteria (angles, 
%     amplitudes, etc) do the actual histogram construction.
% 
% rex_8direction_saccade_analysis - quick way to generate histograms of 
%     spike data for some Rex data based on separating the saccades into 8 
%     directions.
% 
% rds_...  functions called by the user interface of rex_display_saccades.
% 
% rdt_... - functions called by the user interface in rex_display_trials.
% 
% 
% Rex file conversion routines
% 
% rex_process � Given the name of some Rex data files (the A and E files, 
%     without the �A� or �E� on the end), attempts a conversion of this data 
%     into a Matlab file that contains all spike, code, saccade, and other 
%     data.  Allows the optional import of a Dex D file for saccade times.  
%     Data is written to a �.mat� file using the name of the Rex files 
%     given.  (Thus �mineA� and �mineE� become �mine.mat�.)  This function 
%     can be called explicitly, but it is also called by rex_load_processed 
%     if that function cannot find an already converted Rex/Matlab file of 
%     the given name.  See also rex_load_processed and rex_save.
% 
% load_rex_hdr, rex_analog, rex_arecs, rex_ecodes, rex_trial_raw, 
%     rex_numtrials_raw, dex_load_marks, dex_find_saccades_from_marks - low 
%     level routines that do the actual reading from the original Rex A 
%     and E, and Dex D files.
% 
% rawdatadir - override this to provide a data directory for all rex data 
%     files.  Personally I leave this as '' (no directory).
% 
% 
% Additional functions that are not Rex-specific but are needed by these routines:
% 
% find_saccades - determines timing of saccades based on 
%     horizontal/vertical eye movement data.
% 
% probability_density - prob density function based on neural spike 
%     raster data.
% 
% spike_density - spike density function based on neural spike raster data.
% 
% merge_raster
% fat_raster
% cat_variable_size_row
% align_rows_on_indices
% spikehist
% has_all_of
% has_none_of
% has_any_of
%
%
%  EXAMPLE:
%
%  rexname = 'monkeydata';  % This will look for 'monkeydata.mat' 
%  rex_load_processed( rexname );  % Will convert from A and E if not found
%  trial = rex_first_trial( rexname );
%  if trial > 0
%     islast = 0;
%     while ~islast
%         [... make calls to things like rex_trial( rexname, trial ) to get
%         data for this trial ...]
%         [trial, islast] = rex_next_trial( rexname, trial );
%     end;
%  end;
%
%  Add a 1 as another parameter when calling rex_first_trial() and
%  rex_next_trial(), and this example will look at all trials, not just
%  those that are good (not marked as BAD).