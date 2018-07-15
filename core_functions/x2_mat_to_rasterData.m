function x2_mat_to_rasterData(filename, eCodes_fields_entries, RF_Field, RF)

    % This file takes the .mat file and generates the raster data from the file

    % Set the filePath
    filePath = [pwd '/data_files/' filename '_fromNev.mat'];

    % Load the data
    dataStructure = load(filePath);
    data = dataStructure.data; % data is sorted by time

    % Find the rows (indices) where the channel is 0
    % Channel 0 is a marker for eCodes in the second column of 'data'
    %[this might be unnecessary]
    channel0_rows = find(data(:,1) == 0);

    % Extract the eCodes rows into a matrix 
    %[this might be unnecessary]
    eCode_data = data(channel0_rows, :);

    % Get the unique channels in a vector
    unique_channels = unique(data(:,1));

    % Get rid of the channel 0 for easy indexing in the for loop below
    unique_channels(1) = [];

    % Get the number of trials for this experiment
    nTrials = sum(data(:,2) == 1001); % 1001 is the eCode for 'start trial'

    % Get the start index of all the trials
    startIndices = find(data(:,2) == 1001);

    % Declare our rasterData structure array
    rasterData = struct();

    %-----------------------------------%
    %--- Loop through all the trials ---%
    %-----------------------------------%

    % For loop that goes through all the trials
    for i = 1:nTrials

        % Load in the current trial
        currentTrial = i;

        % Define the start index for the current trial's data  
        startIndex = startIndices(currentTrial);

        % Define the end index depending on whether it is the last
        % trial
        if(currentTrial < nTrials)
            endIndex = startIndices(currentTrial+1) - 1;
        else
            endIndex = size(data, 1);
        end

        % Extract the current trial's data
        currentTrial_data = data(startIndex:endIndex,:);

        % Place the trial number in the raster data
        rasterData(currentTrial).trial = currentTrial;

        % Get the timestamp of the start of the trial
        startTrial_time = currentTrial_data(currentTrial_data(:,2)==1001, 3);

        %  Load in the trial start time into rasterData
        rasterData(currentTrial).ENABLECD = startTrial_time;


        % For loop that goes through the different eCodes to extract the
        % data for each eCode in this trial
        for j = 1:3:length(eCodes_fields_entries)

            % Get the current eCode
            currentECode = eCodes_fields_entries{j};

            % Get the field
            currentField = eCodes_fields_entries{j+1};

            % If we want the time that the eCode was dropped
            if(strcmp(eCodes_fields_entries{j+2},'time'))
                rasterData(currentTrial).(currentField) = currentTrial_data(currentTrial_data(:,2)==currentECode, 3) - startTrial_time;
            % Else if we want another field that we specified
            elseif (sum(currentTrial_data(:,2)==currentECode) == 1)
                rasterData(currentTrial).(currentField) = eCodes_fields_entries{j+2};        
            % Else the eCode was not dropped on this trial
            else
                % Deliberately left empty
            end

        end % End of for loop
        

        %-------------------------------------%
        %--- Loop through all the channels ---%
        %-------------------------------------%

        % For loop that goes through all the channels
        for j = 1:length(unique_channels)

            % Load in the current trial
            currentChannel = unique_channels(j);

            % Get the data for the curent channel in this trial
            currentChannel_data = currentTrial_data(currentTrial_data(:,1)==currentChannel, :);

            % Get the unique units for this channel
            unique_units = unique(currentChannel_data(:,2));

            %----------------------------------%
            %--- Loop through all the units ---%
            %----------------------------------%

            % For loop that goes through all the units in this channel
            for k = 1:length(unique_units)

                % Load in the current trial
                currentUnit = unique_units(k);

                % Filter out data for this unit
                currentUnit_data = currentChannel_data(currentChannel_data(:,2)==currentUnit, :);

                % Get the spike times in this unit
                currentUnit_spikeTimes = currentUnit_data(:,3);

                % Load in the spike times for the unit of this channel into
                % rasterData
                rasterData(currentTrial).spikes.(['channel' num2str(currentChannel)]).(['unit' num2str(currentUnit)]) = currentUnit_spikeTimes;

            end % End of currentUnit (k) for loop

        end % End of currentChannel (j) for loop
        
        % If the column to determine the receptive field exists in this
        % trial, then we check if it is in the receptive fiend
        if(isfield(rasterData, RF_Field) && ~isempty(rasterData(currentTrial).(RF_Field)))
            
            % If this trial is in the receptive field, then we add it to the
            % rasterData
            if(strcmp(rasterData(currentTrial).(RF_Field), RF))
                rasterData(currentTrial).inRF = 1;
            else 
                rasterData(currentTrial).inRF = 0;
            end
            
        end

    end % End of currentTrial (i) for loop

    % Save the raster data
    savingFilename = [filename '_rasterData.mat']; % Name of file
    savingPath = [pwd '/data_files']; % Location to save the file in
    save([savingPath '/' savingFilename], 'rasterData'); % Save the file
    
end % End of function