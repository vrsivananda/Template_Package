function x3_rasterData_to_alignedData(filename, RF_Field, RF, alignmentBuffer, alignment_parameters, error_fields, sigma)
    
    % This file takes in the rasterData and processes it to be ready to be
    % plotted

    % Set the filePath
    filePath = [pwd '/data_files/' filename '_rasterData.mat'];

    % Load the data
    dataStructure = load(filePath);
    rasterData = dataStructure.rasterData;

    % Smoothing parameter set-up
    kernel = normpdf((-sigma*3):0.001:(sigma*3), 0, sigma) * 0.001;

    % --------- Extract and align the spiking data --------- %

    % Declare a struct for the data
    alignedData = struct();

    % For loop that goes through each trial and populates the aligned data
    for i = 1:length(rasterData)

        % Load in the current trial
        currentTrial = i;

        % Get the trial start time
        currentTrial_startTime = rasterData(currentTrial).ENABLECD;
        
        % Reset the flag to not skip this trial
        skipTrial = 0;
        
        % For loop that loops through the error cell array and checks for an error
        for j = 1:length(error_fields)
            % If this trial has an error, then set the flag to skip this trial
            if(rasterData(currentTrial).(error_fields{j}))
                skipTrial = 1;
                break;
            end % End of if
        end % End of error_fields for loop (j)
        
        % Skip the trial if need be
        if(skipTrial)
            continue;
        end

        % Check if the target was in the receptive field
        if(rasterData(currentTrial).inRF == 1)
            RF_field = 'inRF';
        elseif(rasterData(currentTrial).inRF == 0)
            RF_field = 'notInRF';
        % Else if we were unable to determine if it was in RF, then we just
        % continue to the next trial
        elseif(isempty(rasterData(currentTrial).inRF))
            continue;
        % Else throw the error
        else
            error('Unable to determine if inRF');
        end

        % Load in the current coherence
        currentCoherenceField = ['coherence' num2str(rasterData(currentTrial).Coherence)];

        % Get the unique channels in a cell array
        unique_channels = fieldnames(rasterData(currentTrial).spikes);

        % For loop that goes through the unique channels
        for j = 1:length(unique_channels)

            % Load in the current channel
            currentChannel = unique_channels{j};

            % Get the unique units for this channel in a cell array
            unique_units = fieldnames(rasterData(currentTrial).spikes.(currentChannel));

            % For loop that goes through the unique units
            for k = 1:length(unique_units)

                % Load in the current unit
                currentUnit = unique_units{k};

                % If the currentUnit is 0, then we ignore the data and move on
                % to the next unit
                if (currentUnit == 'unit0')
                    continue;
                end

                % Load in the spike times for the current unit
                currentUnit_spikeTimes = rasterData(currentTrial).spikes.(currentChannel).(currentUnit);

                % Create a fieldname for the neuron
                currentNeuron = [currentChannel '_' currentUnit];

                % For loop that goes through all our alignment parameters
                for l = 1:3:length(alignment_parameters)

                    % -- Align the data --

                    % Get the current alignment field
                    alignmentField = alignment_parameters{l};

                    % Get the starting and ending alignments
                    alignmentStart = alignment_parameters{l+1};
                    alignmentEnd   = alignment_parameters{l+2};

                    % Place the alignmentStart time and buffer into alignedData
                    alignedData.(alignmentField).(currentCoherenceField).alignmentStart = alignmentStart;
                    alignedData.(alignmentField).(currentCoherenceField).alignmentBuffer = alignmentBuffer;

                    % Calculate the length of the current alignment array,
                    % including the buffer on both ends
                    alignmentLength = alignmentEnd - alignmentStart + (2*alignmentBuffer);

                    % Get the alignment time for the current alignment field
                    alignmentTime = rasterData(currentTrial).(alignmentField);
                    
                    % If there is no alignmentTime, then we skip this trial
                    % Sometimes the last trial ends abrubtly before an 
                    % error is thrown
                    if(isempty(alignmentTime))
                        continue;
                    end

                    % Align the times to the alignmentField time,
                    % convert to milliseconds, and round to nearest millisecond
                    aligned_spikeTimes = ceil((currentUnit_spikeTimes - (currentTrial_startTime + alignmentTime)) * 1000);

                    % Truncate the aligned spike time data to the window that
                    % we want
                    aligned_spikeTimes = aligned_spikeTimes(...
                                            (aligned_spikeTimes > (alignmentStart-alignmentBuffer)) &...
                                            (aligned_spikeTimes < (alignmentEnd+alignmentBuffer)));

                    % Subtract the start time and add the buffer to fit it into
                    % our array (i.e. make them all positive)
                    aligned_spikeTimes = aligned_spikeTimes - alignmentStart + alignmentBuffer; 

                    % Set up the array of values that we are interested in
                    alignmentField_array = zeros(1,(alignmentLength));

                    % Place a '1' in the locations where a spike happened
                    alignmentField_array(aligned_spikeTimes) = 1;

                    % -- Create fields if they don't exist --

                    % If this alignmentField does not exist in alignedData yet,
                    % then we create the field
                    if(~isfield(alignedData, alignmentField))
                        alignedData.(alignmentField) = struct();
                    end

                    % If the current coherence does not exist yet, then we
                    % create the field
                    if(~isfield(alignedData.(alignmentField), currentCoherenceField))
                        alignedData.(alignmentField).(currentCoherenceField) = struct();
                    end

                    % If the current RF does not exist yet, then we create the
                    % field
                    if(~isfield(alignedData.(alignmentField).(currentCoherenceField), RF_field))
                        alignedData.(alignmentField).(currentCoherenceField).(RF_field) = struct;
                    end

                    % If the current neuron does not exist yet, then we create the
                    % field
                    if(~isfield(alignedData.(alignmentField).(currentCoherenceField).(RF_field), currentNeuron))
                        alignedData.(alignmentField).(currentCoherenceField).(RF_field).(currentNeuron) = [];
                    end

                    % -- Concatenate the finding into the matrix --

                    % Get the matrix of the current coherence and alignment
                    % fields
                    currentAlignmentMatrix = alignedData.(alignmentField).(currentCoherenceField).(RF_field).(currentNeuron);

                    % Store the array in our alignedData structure array
                    alignedData.(alignmentField).(currentCoherenceField).(RF_field).(currentNeuron) = ...
                        [currentAlignmentMatrix; alignmentField_array];

                end % End of alignment_parameters for loop (l)

            end % End of unique_units for loop (k)

        end % End of unique_channels for loop (j)

    end % End of trials for loop (i)


    % --------- Process the spiking data --------- %

    % Get the fieldnames of alignedData
    alignmentFields = fieldnames(alignedData);

    % For loop that goes through each of the alignment fields in alignedData
    for i = 1:numel(alignmentFields)

        % Load in the current alignmentField
        alignmentField = alignmentFields{i};

        % Get the coherences array for this alignment field
        coherences = fieldnames(alignedData.(alignmentField));

        % For loop that goes through each of the coherences
        for j = 1:numel(coherences)

            % Load in the current coherence
            currentCoherence = coherences{j};

            % Create an RF_array to loop through
            RF_array = {'inRF', 'notInRF'};

            for k = 1:numel(RF_array)

                % Load in the currentInRF
                currentInRF = RF_array{k};

                % Get the list of neurons for this alignmentField and coherence
                neurons = fieldnames(alignedData.(alignmentField).(currentCoherence).(currentInRF));

                % Delclare a matrix to store the summed conv data across all
                % neurons
                all_neurons_summed_conv = [];

                % For loop that goes through each of the neurons
                for l = 1:numel(neurons)

                    % Load in the current neuron
                    currentNeuron = neurons{l};

                    % Get the data for this neuron
                    dataInRF = alignedData.(alignmentField).(currentCoherence).(currentInRF).(currentNeuron);

                    % Get the measurements of this neuron's data (to be used in
                    % trimming below)
                    dataLength = size(dataInRF, 2); 

                    % Declare a matrix for the convolution data of this neuron
                    currentNeuron_convData = [];

                    % For loop that goes through each trial of this neuron
                    for m = 1:size(dataInRF, 1)

                        % Get the current trial's data for this neuron
                        currentTrial_data = dataInRF(m,:);

                        % Get the convolution 
                        convolution = conv(currentTrial_data, kernel);

                        % Get the difference in length between the conv and the
                        % data and calculate the starting and ending position to 
                        % trim
                        lengthDiff = length(convolution) - length(currentTrial_data);
                        trim_startPos = ceil(lengthDiff/2);
                        trim_endPos = trim_startPos + dataLength - 1;

                        % Trim the convolution (because convoluting produces
                        % artefacts at both sides of the data)
                        convolution = convolution(trim_startPos:trim_endPos);

                        % Store the convolution in the data store
                        currentNeuron_convData(m,:) = convolution;

                    end % End of neuron trial for loop (m)

                    % Sum the conv data of this neuron across trials
                    summed_conv = sum(currentNeuron_convData);

                    % Store the summed_conv data in a store for all neurons
                    all_neurons_summed_conv = [all_neurons_summed_conv; summed_conv];

                    % Place the data into our alignedData
                    alignedData.(alignmentField).(currentCoherence).(currentInRF).all_neurons_summed_conv = all_neurons_summed_conv;

                    % Average the data across the rows and place it our alignedData
                    alignedData.(alignmentField).(currentCoherence).(currentInRF).avg_summed_conv = mean(all_neurons_summed_conv, 1);

                end % End of neuron for loop (l)

            end % End of RF_array for loop (k)

        end % End of coherences for loop (j)

    end % End of alignmentFields for loop

    % Save the raster data
    savingFilename = [filename '_alignedData.mat']; % Name of file
    savingPath = [pwd '/data_files']; % Location to save the file in
    save([savingPath '/' savingFilename], 'alignedData'); % Save the file

end % End of function




