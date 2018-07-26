function x3_rasterData_to_alignedData(filename, alignmentBuffer, alignment_parameters, error_fields, sigma)
    
    % This file takes in the rasterData and processes it to be ready to be
    % plotted

    % Set the filePath
    filePath = [pwd '/data_files/' filename '_rasterData.mat'];

    % Load the data
    dataStructure = load(filePath);
    rasterData = dataStructure.rasterData;

    % Smoothing parameter set-up
    kernel = normpdf((-sigma*3):0.001:(sigma*3), 0, sigma) * 0.001;
    
    
    
    %----------------------------------------------------%
    %    PART 1/2: Extract and align the spiking data    %
    %----------------------------------------------------%
    
    % Declare a struct for the data
    alignedData = struct();

    % For loop that goes through each trial and populates the aligned data
    for i = 1:length(rasterData)
        
        % Load in the trial number
        currentTrial = i;

        % Get the trial start time
        currentTrial_startTime = rasterData(currentTrial).ENABLECD;
        
        % --- Error checking start ---
        
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
        
        % --- Error checking end ---
        
        % --- RF check start ---

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
        
        % --- RF check end ---
        
        % We need to add a '0' if the coherence is less than 10
        if(rasterData(currentTrial).Coherence < 10)
            buffer = '0';
        else
            buffer = '';
        end

        % Load in the current coherence
        currentCoherenceField = ['coherence' buffer num2str(rasterData(currentTrial).Coherence)];

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
                if (strcmp(currentUnit, 'unit0'))
                    continue;
                end

                % Load in the spike times for the current unit
                currentUnit_spikeTimes = rasterData(currentTrial).spikes.(currentChannel).(currentUnit);

                % Create a fieldname for the neuron
                currentNeuron = [currentChannel '_' currentUnit];

                % For loop that goes through all our alignment parameters
                for l = 1:size(alignment_parameters,1) 

                    % ---------- Align the data ----------

                    % Get the current alignment field
                    alignmentField = alignment_parameters{l,1};

                    % Get the starting and ending alignments
                    alignmentStart = alignment_parameters{l,2};
                    alignmentEnd   = alignment_parameters{l,3};

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
                    spikeTrain = zeros(1,(alignmentLength));
                    
                    % Place a '1' in the locations where a spike happened
                    spikeTrain(aligned_spikeTimes) = 1;
                    
                    

                    % ---------- Create fields if they don't exist ----------
                    
                    % Neuron
                    if(~isfield(alignedData, currentNeuron))
                        alignedData.(currentNeuron) = struct();
                    end
                    
                    % Alignment Field
                    if(~isfield(alignedData.(currentNeuron), alignmentField))
                        alignedData.(currentNeuron).(alignmentField) = struct();
                    end
                    
                    % RF Field
                    if(~isfield(alignedData.(currentNeuron).(alignmentField), RF_field))
                        alignedData.(currentNeuron).(alignmentField).(RF_field) = struct();
                    end
                    
                    % Coherence
                    if(~isfield(alignedData.(currentNeuron).(alignmentField).(RF_field), currentCoherenceField))
                        alignedData.(currentNeuron).(alignmentField).(RF_field).(currentCoherenceField) = struct();
                    end
                    
                    % Spike Trains
                    if(~isfield(alignedData.(currentNeuron).(alignmentField).(RF_field).(currentCoherenceField), 'spikeTrains'))
                        alignedData.(currentNeuron).(alignmentField).(RF_field).(currentCoherenceField).spikeTrains = [];
                    end
                    
                    % ---------- Concatenate the finding into the matrix ----------
                    
                    alignedData.(currentNeuron).(alignmentField).(RF_field).(currentCoherenceField).spikeTrains = ...
                        [alignedData.(currentNeuron).(alignmentField).(RF_field).(currentCoherenceField).spikeTrains;...
                        spikeTrain];

                end % End of alignment_parameters for loop (l)                

            end % End of unique_units for loop (k)

        end % End of unique_channels for loop (j)

    end % End of trials for loop (i)


    %------------------------------------------%
    %    PART 2/2: Process the spiking data    %
    %------------------------------------------%
    
    % Get the list of neurons to loop through
    neurons = fieldnames(alignedData);
    
    % For loop that goes through each neuron
    for i = 1:length(neurons)
        
        % Load in current neuron
        currentNeuron = neurons{i};
        
        % For loop that goes through each alignment field
        for j = 1:size(alignment_parameters,1)        
            
            % Get the current alignment field
            alignmentField = alignment_parameters{j,1};
            
            % Create cell array of RF fields to loop through
            RF_fields = {'inRF', 'notInRF'};
            
            % For loop that goes through each RF field
            for k = 1:length(RF_fields)
                
                % Get the current RF field
                RF_field = RF_fields{k};
                
                % Get the list of coherences in a cell array
                coherences = fieldnames(alignedData.(currentNeuron).(alignmentField).(RF_field));
                
                % For loop that goes through each coherence field
                for l = 1:length(coherences)
                    
                    % Prepare the matrix to store the convolutions
                    convolutions = [];
                    
                    % Get the current coherence
                    currentCoherence = coherences{l};
                    
                    % Get the spike trains
                    spikeTrains = alignedData.(currentNeuron).(alignmentField).(RF_field).(currentCoherence).spikeTrains;
                    
                    % Get the length of the spike train (this includes the
                    % buffer)
                    spikeTrainLength = size(spikeTrains,2);
                    
                    % For loop that goes through each trial in the spike
                    % train
                    for m = 1:size(spikeTrains,1)
                        
                        % Get the spike train for the current trial
                        spikeTrain = spikeTrains(m,:);
                        
                        % Run the convolution
                        convolution = conv(spikeTrain, kernel);
                        
                        % Trim the convolution down to the original size
                        convolution = convolution(...
                            ((length(convolution)-spikeTrainLength)/2):...
                            spikeTrainLength + ((length(convolution)-spikeTrainLength)/2));
                        
                        % Store the convolution into the matrix
                        convolutions = [convolutions; convolution];
                        
                    end % End of loop that goes through each trial in the spike train (m)
                    
                    % Store the convolutions for this
                    % neuron/alignmentField/RF_field/coherence into the
                    % alignedData
                    alignedData.(currentNeuron).(alignmentField).(RF_field).(currentCoherence).convolvedSpikeTrains = convolutions;
                    
                    % Sum the convolutions
                    summedConvolutions = mean(convolutions, 1)*1000;
                    %plot(summedConvolutions);
                    %hold on;
                    
                    % Store the summed convolutions
                    alignedData.(currentNeuron).(alignmentField).(RF_field).(currentCoherence).summedConvolutions = summedConvolutions;
                    
                end % End of for loop that goes through each coherence (l)
            
            end % End of for loop that goes through RF field (k)
            
        end % End of alignment parameters for loop (j)
            
    end % End of neuron for loop (i)    
    
    % Save the raster data
    savingFilename = [filename '_alignedData.mat']; % Name of file
    savingPath = [pwd '/data_files']; % Location to save the file in
    save([savingPath '/' savingFilename], 'alignedData'); % Save the file
    
end % End of function




