function [sstarts, sends] =  dex_find_saccades_from_marks( trial, hmarks, vmarks )

%  [sstarts, sends] = dex_find_saccades_from_marks( trial, hmarks, vmarks );
%
%  Return the start and end times of saccades given lines of marks from a
%  DEX file.  hmarks and vmarks can be gotten by calling 
%  dex_load_marks( filename ), where filename is the complete DEX file name.
%
%  In DEX, 'i' on the horizontal or vertical eye trace marks the begining
%  of a saccade, and a 'p' marks the end (according to the DEX manual, 
%  "End of pulse-driven part of saccade", page 10).
%
%  The logic is to look through row 'trial' of hmarks and vmarks, until an
%  'i' is encountered in either, and then read forward until:
%      - if 'i' was found in hmark only so far, and a 'p' is encountered in
%        hmark
%      - likewise for vmark
%      - if 'i's have been found in both, go until 'p's are found in both
%        and no further 'i's
%  A flag is set for each 'i' found, so both channels must reset the 'i'
%  flag (by finding 'p's) before the end of the saccade can be declared
%  found.

sstarts = [];
sends = [];

sz = size( hmarks );
if trial > sz(1)
    return;
end;

thmarks = hmarks( trial, : );
tvmarks = vmarks( trial, : );

hiflag = 0;
viflag = 0;
hpflag = 0;
vpflag = 0;
saccadestarted = 0;
endwithnostart = 0;
nexts = 1;

for d = 1:sz(2)
    if d <= length( thmarks ) && thmarks( d ) == 'i'
        hiflag = 1;
    end;
    
    if d <= length( tvmarks ) && tvmarks( d ) == 'i'
        viflag = 1;
    end;
    
    if d <= length( thmarks ) && thmarks(d) == 'p'
        hpflag = 1;
        if hiflag
            hiflag = 0;
        else
            endwithoutstart = 1;
        end;
    end;
    if d <= length( tvmarks ) && tvmarks(d) == 'p'
        vpflag = 1;
        if viflag 
            viflag = 0;
        else
            endwithoutstart = 1;
        end;
    end;
        
    if ~saccadestarted
        if hiflag || viflag
            saccadestarted = d;
        end;
    end;
    
    %  Here's the critical line.  If we found a 'p', this is the end of
    %  the saccade if and only if both 'i' flags (hiflag and viflag)
    %  are now both 0 (reset).
        
    if hpflag || vpflag
        if ~hiflag && ~viflag && ~endwithnostart
            sstarts(nexts) = saccadestarted;
            sends(nexts) = d;
            nexts= nexts+1;
            saccadestarted = 0;
            hpflag = 0;
            vpflag = 0;
        end;
        hpflag = 0;
        vpflag = 0;
    end;
            
            
    if endwithnostart
        s = sprintf( 'dex_find_saccades_from_marks.m:  While parsing DEX file %s, a saccade end was found without a saccade start in trial %d.', filename, d );
        disp( s );
        endiwthnostart = 0;
    end;
end;
