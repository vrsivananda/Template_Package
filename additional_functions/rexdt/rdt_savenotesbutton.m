function [] = rdt_savenotesbutton

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

rdt_notes = get( rdt_notesedithandle, 'String' );
rex_set_notes( rdt_filename, rdt_notes );
close( rdt_notesfh );
