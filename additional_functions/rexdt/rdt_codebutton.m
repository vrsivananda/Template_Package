function [] = rdt_codebutton

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_ecodes;
global rdt_etimes;

%[ecodeout, etimeout, spkchan, spk, arate, h, v, start_time, rdt_badtrial ] = rex_trial_rca(rdt_filename, rdt_trialnumber, 1);
ecodeout = rdt_ecodes;
etimeout = rdt_etimes;

if isempty(ecodeout)
    disp( 'Something wrong with trial, no codes.' );
else
    secondcode = ecodeout(2);
    s = sprintf( '\n%s trial #%d, code is %d.', rdt_filename, rdt_trialnumber, secondcode );
    if rdt_badtrial
        s= cat( 2, s, '  ABORTED.' );
    end;
    disp( s );

    len = length( ecodeout );
    for d = 1:len
        s = sprintf( '%d at time %d', ecodeout( d ), etimeout( d ) );
        disp( s );
    end;
end;
