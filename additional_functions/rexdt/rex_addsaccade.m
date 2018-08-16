function [] = rex_addsaccade( name, trial, sstart, send )

global rexloadedname rexnumtrials alloriginaltrialnums allnewtrialnums...
    allcodes alltimes allspkchan allspk allrates ...
    allh allv allstart allbad alldeleted allsacstart allsacend...
    allcodelen allspklen alleyelen allsaclen;

if sstart ~= floor( sstart )
    errdlg( 'WHATATTATAT???' );
end;

if trial > 0 && trial <= rexnumtrials
    
    %  This could get tricky.  What happens if we try to add more saccades
    %  than there are currently places for them, given by max( allsaclen )?
    %  Otherwise they're very easy to add.
    
    if allsaclen( trial ) == max( allsaclen )
        disp( 'rex_addsaccade:  Currently there is a limit problem in this function that needs to be fixed.  Saccade not added.' );
    else
        nlen = allsaclen( trial ) + 1;
        allsaclen( trial ) = nlen;
        allsacstart( trial, nlen ) = sstart;
        allsacend( trial, nlen ) = send;
        % put them in order
        allsacstart( trial, 1:nlen ) = sort( allsacstart( trial, 1:nlen ) );
        allsacend( trial, 1:nlen ) = sort( allsacend( trial, 1:nlen ) );
    end;
end;