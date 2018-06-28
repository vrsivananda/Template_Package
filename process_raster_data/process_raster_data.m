% This file takes in the rasterData and processes it to be ready to be
% plotted


% Clear the workspace
clear;

%----------------------------------%
%------ Set parameters begin ------%
%----------------------------------%

% Set the filename
filename = 'SP170126R';

% Coherences
coherences = [0.5, 0.36, 0.24, 0.17, 0.10, 0.05, 0];

% The start and end timings for each of the plots
alignment_parameters = {
    'ChoiceTargetOn',    -200, 800,...
    'GlassPatternCueOn', -600, 600,...
    'Saccade',           -600, 300 ...
};

% The fields which if filled means an error
error_fields = {
    'Error_FP',...
    'Error_Tgt',...
    'Error_EarlySaccade',...
    'Error_ChoseDist',...
    'Error_NoSaccade',...
};

%----------------------------------%
%------- Set parameters end -------%
%----------------------------------%

% Set the filePath
filePath = [pwd '/../data_files/' filename '_rasterData.mat'];

% Load the data
dataStructure = load(filePath);
rasterData = dataStructure.rasterData;

% Declare a matrix for each of the plots
alignedData = struct();

% For loop that goes through each trial
for i = 1:length(rasterData)
    disp(i);
    
    % Load in the current trial
    currentTrial = i;
    
    % Reset the flag to not skip this trial
    skipTrial = 0;
    
    % For loop that loops through the error cell array and checks for an error
    for j = 1:length(error_fields)
        % If this trial has an error, then set the flag to skip this trial
        if(rasterData(currentTrial).(error_fields{j}))
            skipTrial = 1;
        end % End of if
    end % End of error_fields for loop (j)
    
    % Skip the trial if need be
    if(skipTrial)
        continue;
    end
    
    % Load in the current coherence
    currentCoherenceField = ['coherence' num2str(rasterData(currentTrial).Coherence*100)];
    
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
            
            % If the currenUnit is 0, then we ignore the data and move on
            % to the next unit
            if (currentUnit == 0)
                continue;
            end
            
            % Load in the spike times for the current unit
            currentUnit_spikeTimes = rasterData(currentTrial).spikes.(currentChannel).(currentUnit);
            
            % Convert the time to milliseconds and round to nearest
            % millisecond
            % currentUnit_spikeTimes = round(currentUnit_spikeTimes*1000);
            
            % For loop that goes through all our alignment parameters
            for l = 1:3:length(alignment_parameters)
                
                % Get the current alignment field
                alignmentField = alignment_parameters{l};
                
                % Get the starting and ending alignments
                alignmentStart = alignment_parameters{l+1};
                alignmentEnd   = alignment_parameters{l+2};
                
                % Calculate the length of the current alignment
                alignmentLength = alignmentEnd - alignmentStart;
                
                % Get the alignment time for the current alignment field
                alignmentTime = rasterData(currentTrial).(alignmentField);
                
                % Align the times to the currentAlignmentField time,
                % convert to milliseconds, and round to nearest millisecond
                aligned_spikeTimes = round((currentUnit_spikeTimes - alignmentTime) * 1000);
                
                % Truncate the aligned spike time data to the window that
                % we want
                aligned_spikeTimes = aligned_spikeTimes(...
                                        (aligned_spikeTimes >= alignmentStart) &...
                                        (aligned_spikeTimes <= alignmentEnd));
                
                % Subtract the start time to fit it into out array
                aligned_spikeTimes = aligned_spikeTimes - alignmentStart;
                                    
                % Set up the array of values that we are interested in
                alignmentField_array = zeros(1,(alignmentLength));
                
                % Place a '1' in the locations where a spike happened
                alignmentField_array(aligned_spikeTimes) = 1;
                
                % If this AlignmentField does not exist in alignedData yet,
                % then we create the field
                if(~isfield(alignedData, alignmentField))
                    alignedData.(alignmentField) = struct();
                end
                
                % If the current coherence does not exist yet, then we
                % create the field
                if(~isfield(alignedData, currentCoherenceField))
                    alignedData.(alignmentField).(currentCoherenceField) = [];
                end
                
                % Get the matrix of the current coherence and alignment
                % fields
                currentAlignmentMatrix = alignedData.(alignmentField).(currentCoherenceField);
                % ^ Currently this doesn't work very well. Check.
                
                % Store the array in our alignedData structure array
                alignedData.(alignmentField).(currentCoherenceField) = ...
                    [currentAlignmentMatrix; alignmentField_array];
                
            end % End of alignment_parameters for loop (l)
            
        end % End of unique_units for loop (k)
        
    end % End of unique_channels for loop (j)
    
end % End of for loop that goes through every trial (i)
