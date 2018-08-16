function [] = rexdt( taskname )

global rexloadedname;
clear global rexloadedname;

task = '';
if nargin > 0
    task = taskname;
end;


%   [file, dir] = uigetfile( '*.*', 'Pick a REX file to analyze' );
file = 'SP170126BA'; %[sivaHack]

    len = length( file );
    if len > 4 && strcmp( file( len-3:len ), '.mat' )
        file = file( 1:len-4 );
    elseif len>1 && (file(len) == 'A' || file(len) == 'E')
        file = file( 1:len-1 );
    end;
    if len==0 || isempty( file ) || isequal(file,0)
        return;
    end;


 fprintf( 'File is %s\n', file ) ;

rex_display_trials( file, 1, task );

% Siva added this (08/15/18) to change the name of the file so that it is
% unambiguous. 
% - There will be a file with a '_from_rexdt.mat' appended to the end 
% which is saved in the data_files folder

% Load the variables from the saved file:
load([file '.mat']);


% Save it with another name
filename = [file '_from_rexdt'];
filePath = [pwd '/../data_files/' filename]; %pwd here is the path to the folder where this script is in
save( filePath, 'rexloadedname', 'rexnumtrials', 'alloriginaltrialnums', 'allnewtrialnums', 'allcodes', 'alltimes', 'allspkchan', 'allspk', 'allrates', ...
    'allh', 'allv', 'allstart', 'allbad', 'alldeleted', 'allsacstart', 'allsacend',...
    'allcodelen', 'allspklen', 'alleyelen', 'allsaclen', 'allrexnotes');
disp([filename 'is saved in data_files folder']);



% prompt = {'Bin size for histogram (leave blank for 5 ms):',...
%     'Miliseconds before saccade start to gather spike data (default 200):',...
%     'Miliseconds after saccade start to gather spike data (default 200):',...
%     'Type a 1 to include bad trials (leave blank for no bad trials):' };
% 
% dlgname = '8 direction saccade-centered spike analysis';
% 
% 
% answers = inputdlg( prompt, dlgname );
%     if (isempty( answers ) )
%         return;
%     else
%         for d=1:4
%             if isempty( str2num(answers{d} ) )
%                 answerint(d) = 0;
%             else
%                 answerint(d) = str2num( answers{d} );
%             end;
%         end;
%         binsize = answerint(1);
%         includebad = answerint(2);
%         msbefore = answerint(3);
%         msafter = answerint(4);
%     end;
%     
% rex_8direction_saccade_analysis( file )