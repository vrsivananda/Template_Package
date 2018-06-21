% This file takes the .mat file and generates the raster data from the file
% 
% Instructions:
% (1) Fill in the filename (without the '.nev' file extension)
% (2) Run the file


% Clear the workspace
clear;

% Set the filename
filename = '151102Pierre001';
filePath = [pwd '/../data_files/' filename '.mat'];

% Load the data
dataStructure = load(filePath);
data = dataStructure.data;

% Find the rows (indices) where the channel is 0
% Channel 0 is a marker for eCodes in the second column of 'data'
channel0_rows = find(data(:,1) == 0);

% Extract the eCodes rows into a matrix
eCode_data = data(channel0_rows, :);

% Get the unique channels in a vector
unique_channels = unique(data(:,1));

% Get rid of the channel 0 for easy indexing in the for loop below
unique_channels(1) = [];

% Get the number of trials for this experiment
nTrials = sum(data(:,2) == 1001); % 1001 is the eCode for 'start trial'

% For loop that goes through each unique channel
for i = 1:length(unique_channels)
    
    % Load in the currentChannel for easy handling
    currentChannel = unique_channels(i);
    
    % Get the data of the current channel
    currentChannel_data = data(data(:,1) == currentChannel, :);
    
    % Get the units in this channel (unique function sorts implicitly)
    unique_units = unique(currentChannel_data(:,2));
    
    % For loop that goes through each unit in this channel
    for j = 1:length(unique_units)
        
        % Load in the currentUnit for easy handling
        currentUnit = unique_units(j);
        
        % Get the data of the current units
        currentUnit_data = currentChannel_data(currentChannel_data(:,2) == currentUnit, :);
        
        % Concatenate the eCode data to the currentUnit data and sort by
        % time (i.e. chronological order)
        currentUnit_with_eCode_data = sortrows([currentUnit_data; eCode_data], 3);
        
        % Get the total spikes for this unit
        currentUnit_totalSpikes = size(currentUnit_data, 1);
        
        % ---- This stuff below is from the individual
        % extract_raster_data_RFtest.m file -------
        
        xRF = '';
        yRF = '';
        
        % Find the indices of currentUnit data when the trial starts
        currentUnit_trialStart_indices = find(currentUnit_with_eCode_data(:,2) == 1001); 
        
        % Get the number of trials
        currentUnit_nTrials = length(currentUnit_trialStart_indices);
        
        % Preallocate the cell array to hold currentUnit trial data
        currentUnit_trials_cellArray = cell(currentUnit_nTrials, 1);
        
        % Separate the trials and store each trial data in a cell array
        % element
        for k = 1:currentUnit_nTrials
            
            % Define the start and end indices for each trial
            startIndex = currentUnit_trialStart_indices(k);
            
            % Define the end index depending on whether it is the last
            % trial
            if(k < currentUnit_nTrials)
                endIndex = currentUnit_trialStart_indices(k+1) - 1;
            else
                endIndex = size(currentUnit_with_eCode_data, 1);
            end
            
            % Store the trial data into a cell in the cell array
            currentUnit_trials_cellArray{k,1} = currentUnit_with_eCode_data(startIndex:endIndex, :);
            
        end % For loop to make trials
        
    end % End of for loop that goes through each unit in this channel
    
    
    
end % End of for loop that goes through each unique channel





