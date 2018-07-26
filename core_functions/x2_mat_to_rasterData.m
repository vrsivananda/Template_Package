function x2_mat_to_rasterData(filename, eCodes_fields_entries, inRF_parameters)

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
        for j = 1:size(eCodes_fields_entries,1)

            % Get the current eCode
            currentECode = eCodes_fields_entries{j,1};

            % Get the field
            currentField = eCodes_fields_entries{j,2};

            % If we want the time that the eCode was dropped
            if(strcmp(eCodes_fields_entries{j,3},'time'))
                rasterData(currentTrial).(currentField) = currentTrial_data(currentTrial_data(:,2)==currentECode, 3) - startTrial_time;
            % Else if we want another field that we specified
            elseif (sum(currentTrial_data(:,2)==currentECode) == 1)
                rasterData(currentTrial).(currentField) = eCodes_fields_entries{j,3};        
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
        
        % Flag to determine if it was in RF
        inRF = [];
        
        % For loop that checks if this trial has all the info that
        % matches that required for it to be in the receptive field
        for j = 1:size(inRF_parameters,1)
            
            % Load in the variables for the current loop
            inRF_field = inRF_parameters{j,1};
            inRF_info = inRF_parameters{j,2};
            
            % If the column to determine the receptive field exists in this
            % trial, then we check if it is in the receptive field
            if(isfield(rasterData, inRF_field) && ~isempty(rasterData(currentTrial).(inRF_field)))
            
                % Load in the current info
                current_info = rasterData(currentTrial).(inRF_field);
                
                % Check if the current field contains matching info
                if( (ischar(inRF_info)    && strcmp(current_info, inRF_info)) || ...
                        (isnumeric(inRF_info) && (current_info == inRF_info)) )
                    
                    % If yes, then indicate that that the stimuli was in RF
                    inRF = 1;
                    
                else
                    % Else it was not in RF
                    inRF = 0;
                    break; % Break out of for loop
                    
                end % End of inner if that checks for matching info
            
            % Else if the field necessary to determine inRF does not exist,
            % then we break out of the loop
            else
                inRF = [];
                break;
            end % End if that checks for field existence
            
        end % End of inRF_parameters for loop (j)
        
        % Load it into the rasterData
        rasterData(currentTrial).inRF = inRF;

    end % End of currentTrial (i) for loop

    % Save the raster data
    savingFilename = [filename '_rasterData.mat']; % Name of file
    savingPath = [pwd '/data_files']; % Location to save the file in
    save([savingPath '/' savingFilename], 'rasterData'); % Save the file
    
end % End of function