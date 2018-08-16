function [ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, badtrial] = rex_trial_fake(name, trial, includeaborted)

ecodeout = [1001 6020 6220 6420 6620 6820 7020];
etimeout = [1    300  500  700  900  1100 1300];

spkchan = 1;
for d = 1:trial + 10
    spk(d) = 100+(d*2);
end;

arate = 1000;
h = sin( (1:1300)./100 );
v = cos( (1:1300)./100 );

start_time = trial * 1400;
badtrial = 0;
