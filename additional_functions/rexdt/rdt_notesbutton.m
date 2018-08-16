function [] = rdt_notesbutton

global rdt_nt;
global rdt_badtrial;
global rdt_fh;
global rdt_trialnumber;
global rdt_filename;
global rdt_ecodes;
global rdt_etimes;
global rdt_includeaborted;
global rdt_notes;
global rdt_notesedithandle;
global rdt_notesfh;

rdt_notes = rex_get_notes( rdt_filename );
rdt_notesfh = figure;
set( rdt_notesfh, 'Position', [720 320 350 350] );
rdt_notesedithandle = uicontrol('Parent', rdt_notesfh, 'Style', 'edit','String',...
    rdt_notes, 'Position', [10 40 330 290], 'HorizontalAlignment', 'left', 'Max', 100, 'Min', 1);
savebhandle = uicontrol( 'Parent', rdt_notesfh, 'Style', 'pushbutton', 'String', 'Save', 'Position', [10 10 50 20] );
set( savebhandle, 'Callback', 'rdt_savenotesbutton' );

