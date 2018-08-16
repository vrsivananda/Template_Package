function [ecodeout, etimeout, spkchan, spk, arate, h, v, start_time] = rex_trial(name, trial, atrace)

% % function [ecodeout, etimeout, spkchan, spk, arate, h, v, start_time] =
% %       rex_trial(name, trial, atrace)
% % 
% % returns data from REX afile and efile for a given trial 
% % name is the file name root (sans A or E), trial is the
% % desired trial number, and atrace (optional) selects which
% % analog channel to return (default = first channel)
% % by James Cavanaugh 2001


persistent s2l;
persistent sa2la;
persistent currecodename;
persistent ecodes;
persistent etimes;
persistent trialstarttimes;
persistent trialendtimes;
persistent arecs;

NULL = 32768;  % -1 signed int

% short to long conversions
if isempty(sa2la)
	bitlen = '8';
	mult = eval(['2^',bitlen]);
	mult = num2str(mult);
	stype = 'uint';
	s2l = inline(['double(',stype,bitlen,'(s(1)))+',mult,'*double(',stype,bitlen,'(s(2)))'],'s');
	sa2la = inline(['double(',stype,bitlen,'(s(:,1)))+',mult,'.*double(',stype,bitlen,'(s(:,2)))'],'s');
end;

if nargin < 3
	atrace = 1;
end;
if nargin < 2
	trial = 1;
end;


% grab all the ecodes
ecname = [name,'_ecodes'];
etname = [name,'_etimes'];

if ~strcmp(currecodename, ecname)
	currecodename = ecname;
    
	arecs = rex_arecs(name);
	[ecodes, etimes] = rex_ecodes(name);
	
	% trial start and ends
	trialstart = find(ecodes == 1001);
	
	lastevent = length(ecodes);
	trialend = [trialstart(2:end);lastevent];
	
	trialtimes = etimes(trialstart);
	numtrials = length(trialstart);
	
	% remove bad trials
	badtrial = find(ecodes == 17385);  % or so I think...
	if ~isempty(badtrial)
		badtrialtime = etimes(badtrial);
		bad = [];
		for b = 1:length(badtrial)
			bd = max(find(badtrialtime(b) > trialtimes));
			bad = [bad;bd];
		end;
		ok = setxor(bad, (1:numtrials));
		trialstart = trialstart(ok);
		trialend = trialend(ok);
	end;
	
	% find last e-record time
	% not sure this is the right way to do it...
	trialstarttimes = etimes(trialstart);
	trialendtimes = etimes(trialend);
	
end;

% indices of start and end of this trial
idx1 = find((ecodes == 1001) & (etimes == trialstarttimes(trial)));
idx2 = find((ecodes == 1001) & (etimes == trialendtimes(trial)));

idx1 = idx1(end);
idx2 = idx2(end);

% ecodes and times for this trial
currcode = ecodes(idx1:idx2);
currtime = etimes(idx1:idx2);

% find analog references
aidx = find(currcode == -112);
aoffset = currtime(aidx);

%s = sprintf( 

aoffset

aidx

% grab analog data for this trial
adat = [];
if ~isempty(aidx)
	for ofst = 1:length(aoffset)
		[aseq, acd, atm, ausr, acont, adata] = rex_analog(name, aoffset(ofst));
		if ofst == 1
			analog_time = atm;
		end;
		
		% check the returned values
		codeok = (acd == -112);
		contok = (acont == (ofst ~= 1));
		usrok = (ausr == (ofst-1));
		
		if codeok & usrok & contok
        %if codeok
			adat = [adat; adata(:)];
		else
			% something wrong - return null data for this trial
            disp( 'something wrong, returning null data for this trial' );
            s = sprintf( 'code ok %d     usrok %d     contok %d', codeok, contok, usrok );
            disp( s );
            s = sprintf( 'acd=%d     acont=%d     ofst=%d     ausr=%d', acd, acont, ofst, ausr );
            disp( s );
			ecodeout = [];
			etimeout = [];
			spkchan = [];
			spk = [];
			arate = [];
			h = [];
			v = [];
			start_time = [];
			return;
		end;  % data read were ok
	end;  % looping through afile offsets
	
		
	max_samp = arecs.max_samp_rate;
	min_samp = arecs.min_samp_rate;
	store_rate = arecs.store_rate;
	ad_shift = arecs.shift;
	
	% check for proper number of subframes
	sbfrm = max_samp/min_samp;
	
	if sbfrm ~= arecs.num_subframe
		error('Wrong # signals in subframe from samp rates');
	end;
	
	if arecs.numsig ~= length(store_rate)
		arecs.numsig
		store_rate
		error('Wrong # signals in store_rate[]');
	end;
	
	assignin('base','arecs2',arecs);
	% how often do signals appear in subframes
	sfreq = store_rate./min_samp;
	step = sbfrm./sfreq;
	nullstep = sbfrm/2;
	frm = {};

	% which subframes contain which signals
	totsig = 0;
	for s = 1:arecs.numsig
		if store_rate(s) ~= NULL
			frm{s} = 0:step(s):(sbfrm-1);
			totsig = totsig + length(frm{s});
		else
			frm{s} = 0:nullstep:(sbfrm-1);
			totsig = totsig + length(frm{s});
		end;
	end;

	if totsig ~= arecs.sig_in_frm
		totsig
		arecs.sig_in_frm
		error('Calculated wrong # signals in frame');
	end;

	
	% show how signals are laid out in linear frame
	sigs = [];
	for f = 0:(sbfrm-1)
		for s = 1:arecs.numsig
			whichfrm = frm{s};
			if ~isempty(find(f==whichfrm))
				sigs = [sigs;s];
			end;
		end;
	end;
	
	if 0
        
 disp('WACKO!!!');
		% sigs shows which shorts belong to which signal in a frame
		sigs = [sigs,sigs];
		sigs = reshape(sigs', prod(size(sigs)), 1);
		% sigs now shows which bytes belong to which signal

		numa = length(adat);
		totnumfrm = numa/length(sigs);
		allidx = [];

		% handles when storage is turned off mid-trial
		totnumfrm = floor(totnumfrm);
		numa = length(sigs)*totnumfrm;


		allidx = reshape(sigs(:)*ones(1,totnumfrm), numa, 1);

		hrate = store_rate(1);
		vrate = store_rate(2);
		hsig = adat(allidx == 1);
		vsig = adat(allidx == 2);

		hsig = reshape(hsig, 2, prod(size(hsig))/2);
		vsig = reshape(vsig, 2, prod(size(vsig))/2);
		hsig = hsig';
		vsig = vsig';


		% analog data are split in 2 - recombine 2 shorts into single long
		for x = 1:2
			% which 2 streams to look at
			if x == 1
				sig = hsig;
			else
				sig = vsig;
			end;

			shift_calib = ad_shift(x);
			col1 = sig(:,1);
			col2 = sig(:,2);



			% 		a = sa2la([col1,col2]);
			a = col2.*256 + col1;

			a = bitshift(a, -shift_calib);
			a = a - arecs.a_d_radix_comp;
			a = a./40;

			wrap = find(a > 51.2);
			a(wrap) = 0-(102.4 - a(wrap));

			if x == 1
				h = a;
			elseif x == 2
				v = a;
			end;
		end;

	else
		adat = shorts2longs(adat);

		numa = length(adat);
		totnumfrm = numa/length(sigs);
		allidx = [];

		% handles when storage is turned off mid-trial
		totnumfrm = floor(totnumfrm);
		numa = length(sigs)*totnumfrm;
		allidx = reshape(sigs(:)*ones(1,totnumfrm), numa, 1);
		hsig = adat(allidx==1);
		vsig = adat(allidx==2);
		
		hrate = store_rate(1);
		vrate = store_rate(2);

		h = bitshift(hsig, -ad_shift(1));
		h = h - arecs.a_d_radix_comp;
		% turn into signed ints
		h = u16tos16(h, -ad_shift(1));
		h = h./40;

		v = bitshift(vsig, -ad_shift(2));
		v = v - arecs.a_d_radix_comp;
		v = u16tos16(v, -ad_shift(2));
		v = v./40;

	end;

else
	analog_time = etimes(1);
	h = [];
	v = [];
end;

% user-defined ecodes
eidx = find(currcode > 999);
ecodeout = currcode(eidx);
etimeout = currtime(eidx) - analog_time;

if nargout == 8
	start_time = analog_time;
end;

% spikes!
sidx = find(currcode > 600 & currcode < 700);

uspk = sort(unique(currcode(sidx)));
numspkchan = length(uspk);

% each channels spikes are in a cell in array spk
if numspkchan == 0
	spkchan = [];
	spk = [];
else
	for s = 1:numspkchan
		spkchan(s) = uspk(s);
		spk{s} = currtime(find(currcode == uspk(s))) - analog_time;
	end;  % looping through spike channels
end;

if ~isempty(h)
	% subsample analog signals if necessary
	% analog x is per millisecond
	hinc = floor(1000/hrate);
	vinc = floor(1000/vrate);
	ehx = (0:(length(h)-1)).*hinc;
	evx = (0:(length(v)-1)).*vinc;
	
	% subsample higher rate analog channel to match lower rate
	if hrate > vrate  % subsample h
		arate = vrate;
		hidx = 1:vinc:length(h);
		h = h(hidx);
	elseif vrate > hrate  % subsample v
		arate = hrate;
		vidx = 1:hinc:length(v);
		v = v(vidx);
	else
		arate = hrate;
	end;
	
	if length(h) ~= length(v)
		length(h)
		length(v)
		error('Problem subsampling analog channels');
	end;
	
	ainc = 1000/arate;
else
	arate = [];
end;
