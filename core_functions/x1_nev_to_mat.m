function x1_nev_to_mat(filename)

    % This script will take a .nev file in the data_files folder, read it, then
    % save a .mat file back into the data_files folder.
    % All you have to do is set the variable 'filename' to the name of the .nev 
    % file (without the .nev file extension). 
    % The file that is saved in the data_files folder will have the same name
    % but have a .mat file extension instead.

    % Set the NEV file name (to be read)
    fullFilename = [filename '.nev'];

    % Read the NEV file into 'data'
    data = NEV_reader([pwd '/data_files/' fullFilename]);

    % Save the data
    savingFilename = [filename '_fromNev.mat']; % Name of file
    savingPath = [pwd '/data_files']; % Location to save the file in
    save([savingPath '/' savingFilename], 'data'); % Save the file

end % End of function