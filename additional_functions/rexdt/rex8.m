function [] = rex8( filename )

if nargin < 1
    [file, dir] = uigetfile( '*.*', 'Pick a REX file to analyze' );

    len = length( file );
    if len==0 || isempty( file ) || isequal(file,0)
        return;
    end;
    
    if len > 4 && strcmp( file( len-3:len ), '.mat' )
        file = file( 1:len-4 );
    elseif len>1 && (file(len) == 'A' || file(len) == 'E')
        file = file( 1:len-1 );
    end;
    filename = file;
end;

prompt = {'Bin size for histogram (leave blank for 5 ms):',...
    'Miliseconds before saccade start to gather spike data (default 200):',...
    'Miliseconds after saccade start to gather spike data (default 200):',...
    'Type a 1 to include bad trials (leave blank for no bad trials):' };

dlgname = '8 direction saccade-centered spike analysis';


answers = inputdlg( prompt, dlgname );
if (isempty( answers ) )
    return;
end;
    
for d=1:4
    if isempty( str2num(answers{d} ) )
        answerint(d) = 0;
    else
        answerint(d) = str2num( answers{d} );
    end;
end;
binsize = answerint(1);
includebad = answerint(4);
msbefore = answerint(2);
msafter = answerint(3);
        
if binsize == 0
    binsize = 5;
end;
if msbefore == 0
    msbefore = 200;
end;
if msafter == 0
    msafter = 200;
end;

rex_8direction_saccade_analysis( filename, msbefore, msafter, binsize, includebad );