function [ecode, etime] = rex_ecodes(name)% % function [ecode, etime] = rex_ecodes(name)% % returns all ecodes and their times for a given rex experiment% % by James Cavanaugh 2001hdrsz = 512;% short to long conversionsif ~exist('sa2la')    s2l = inline('double(uint8(s(1)))+256*double(uint8(s(2)))','s');    sa2la = inline('double(uint8(s(:,1)))+256.*double(uint8(s(:,2)))','s');        assignin('base','s2l',s2l);    assignin('base','sa2la',sa2la);end;name = char(deblank(name));% set up the file namesfname = [rawdatadir,name];ename = [fname,'E'];% open the event and analog filesbyteorder = 'ieee-le';  % good for mac and pc - tweak for other platformsefp = fopen(ename, 'r', byteorder);if efp == -1	errordlg(['Raw data not found for ',fname],...		'Raw Data File Not Found');	return;end;% find distance from 512 to end% here's the endfseek(efp, 0, 'eof');endpt = ftell(efp);% here's the distancenumdat = (endpt - hdrsz)/2;  % /2 since we're going to read shorts% back to just after the headerfseek(efp, hdrsz, 'bof');toread = numdat;% read the data in one big chunk - faster[alldat, nread] = fread(efp, toread, 'short');numrec = numdat/4;  % rows are 4 bytes wide - hence /4% shape the stream into a numrec x 4 arrayedat = reshape(alldat(1:(4*numrec)), 4, numrec)';% columns 3 and 4 are parts of a long% first: convert these shorts into ushortsnegshort = find(edat(:,3) < 0);edat(negshort,3) = (2^16)+edat(negshort,3);% second: convert each pair into a longoffset = (2^16).*edat(:,4) + edat(:,3);% pull out the valuese_time = offset;e_code = edat(:,2);fclose(efp);if nargout   ecode = e_code;   etime = e_time;end;