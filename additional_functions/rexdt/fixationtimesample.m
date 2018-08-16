
%load neuron.mat

% This code gets the neural data, the eye data, and the time of the 66xy
% code (fixation off for gap tasks) and the 68xy code (target on for gap
% tasks).  The neural and eye data will be put in matrices where each row
% is a trial.  The time data will be put in two lists.
counter=1;
eyehoriz = [];
eyevert = [];
rasters = [];
nexttrial = 1;
time66xy = [];
time68xy = [];
allowbadtrials = 0;

%update=2;
name = 'hpb16n3';
neuron(update).name= 'hpb16n3';
neuron(update).condition = 10.0;
neuron(update).fixtimes=[];



trialcodes = [7260];
endcodes = trialcodes + 600;

structarrayindex = 1;

trial = rex_first_trial( name, allowbadtrials );
islast = (trial == 0);

while ~islast

%  Get all the trial data for the next valid trial.

[ecodes, codetimes, spkchan, spk, arate, horiz, vert] = rex_trial( name, trial );

if has_any_of( trialcodes, ecodes )

%  Add a new element to the structure array.



[sstarts, sends] = rex_trial_saccade_times( name, trial );
for i = length( trialcodes )
f = [];
f = find( ecodes == trialcodes(i) );
if ~isempty( f )
startcodetime = codetimes( f(1) );
end;
f = [];
f = find( ecodes == endcodes( i ) );
if ~isempty( f )
endcodetime = codetimes( f(1) );
end;
end;

for st = 1:length( sstarts )-1
if (sstarts( st+1 ) < endcodetime ) && (sends(st) > startcodetime)
% This is a saccade we want.

sacduration = sends( st ) - sstarts( st );
fixduration = sstarts( st+1 ) - sends( st );

array{structarrayindex,update}= fixduration;

structarrayindex = structarrayindex+1;


% Add these to the array inside the new element.

%  It is up to you to figure out what to do with
%  fixduration, like put it in an array, or print it out,
%  or feed it to a duck.

end;
end;



end;


%  Move on to the next trial.

[trial, islast] = rex_next_trial( name, trial, allowbadtrials );

end;


neuron(update).fixtimes=array(:,update);
save neuron6 neuron
update=update+1

s = sprintf( 'Total trials:  %d, mean fixation off time: %d, mean target on time: %d.', ...
nexttrial, floor( mean( time66xy ) ), floor( mean( time68xy ) ) );
disp( s );
