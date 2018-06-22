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

% Set the receptive field neurons
xRF = -139; % This needs to be set
yRF = -3; % This needs to be set

% Set the RF eCodes
xRF_eCode       = 15000 + xRF;
opp_xRF_eCode   = 15000 - xRF;
yRF_eCode       = 15000 + yRF;
opp_yRF_eCode   = 15000 - yRF;

% Load the data
dataStructure = load(filePath);
data = dataStructure.data; % data is sorted by time

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

% Get the start index of all the trials
startIndices = find(data(:,2) == 1001);

% Declare our rasterData structure array
rasterData = {};

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
    
    % Extract the times for the ecodes and store it in a structure array
    rasterData(currentTrial).ENABLECD_Time  =   currentTrial_data(currentTrial_data(:,2)==1001, 3);
    rasterData(currentTrial).TGTONCD        =   currentTrial_data(currentTrial_data(:,2)==2000, 3) - startTrial_time;
    rasterData(currentTrial).DISTSONCD      =   currentTrial_data(currentTrial_data(:,2)==2009, 3) - startTrial_time;
    rasterData(currentTrial).FPONCD         =   currentTrial_data(currentTrial_data(:,2)==2500, 3) - startTrial_time;
    rasterData(currentTrial).FPOFFCD        =   currentTrial_data(currentTrial_data(:,2)==3000, 3) - startTrial_time;
    rasterData(currentTrial).TGTOFFCD       =   currentTrial_data(currentTrial_data(:,2)==4000, 3) - startTrial_time;
    rasterData(currentTrial).DSOFFCD        =   currentTrial_data(currentTrial_data(:,2)==4100, 3) - startTrial_time;
    rasterData(currentTrial).CUEONCD        =   currentTrial_data(currentTrial_data(:,2)==5000, 3) - startTrial_time;
    rasterData(currentTrial).CUEOFFCD       =   currentTrial_data(currentTrial_data(:,2)==5500, 3) - startTrial_time;
    rasterData(currentTrial).EYEINTGTCD     =   currentTrial_data(currentTrial_data(:,2)==5075, 3) - startTrial_time;
    rasterData(currentTrial).REWCD          =   currentTrial_data(currentTrial_data(:,2)==5050, 3) - startTrial_time;
    rasterData(currentTrial).STIMCD         =   currentTrial_data(currentTrial_data(:,2)==2998, 3) - startTrial_time;
    rasterData(currentTrial).STOFFCD        =   currentTrial_data(currentTrial_data(:,2)==2999, 3) - startTrial_time;
    rasterData(currentTrial).MEMCD          =   currentTrial_data(currentTrial_data(:,2)==2222, 3) - startTrial_time;
    rasterData(currentTrial).VISCD          =   currentTrial_data(currentTrial_data(:,2)==3333, 3) - startTrial_time;
    rasterData(currentTrial).ENDCD          =   currentTrial_data(currentTrial_data(:,2)==6000, 3) - startTrial_time;
    rasterData(currentTrial).SACCD          =   currentTrial_data(currentTrial_data(:,2)==1503, 3) - startTrial_time;
    rasterData(currentTrial).ERRCD          =   currentTrial_data(currentTrial_data(:,2)==6999, 3) - startTrial_time;
    rasterData(currentTrial).FIXTRIAL       =   currentTrial_data(currentTrial_data(:,2)==1500, 3) - startTrial_time;
    rasterData(currentTrial).SACCADERT      =   currentTrial_data(currentTrial_data(:,2)==1501, 3) - startTrial_time;
    rasterData(currentTrial).SACCADELT      =   currentTrial_data(currentTrial_data(:,2)==1502, 3) - startTrial_time;
    rasterData(currentTrial).STEPONCD       =   currentTrial_data(currentTrial_data(:,2)==6001, 3) - startTrial_time;
    rasterData(currentTrial).STEPOFFCD      =   currentTrial_data(currentTrial_data(:,2)==6002, 3) - startTrial_time;
    rasterData(currentTrial).RAMPONCD       =   currentTrial_data(currentTrial_data(:,2)==7000, 3) - startTrial_time;
    rasterData(currentTrial).RAMPOFFCD      =   currentTrial_data(currentTrial_data(:,2)==7001, 3) - startTrial_time;
    rasterData(currentTrial).RAMPSPCD       =   currentTrial_data(currentTrial_data(:,2)==7002, 3) - startTrial_time;
    
    
    
    
    % Check if the target is in the receptive field, and add it to
    % rasterData
    
    % If the target was in the RF
    if (sum(ismember(currentTrial_data(:,2),xRF_eCode)) > 0) && (sum(ismember(currentTrial_data(:,2),yRF_eCode)) > 0)
        rasterData(currentTrial).TGinRF = 1;
    % Else if the target was opposite to RF
    elseif (sum(ismember(currentTrial_data(:,2),opp_xRF_eCode)) > 0) && (sum(ismember(currentTrial_data(:,2),opp_yRF_eCode)) > 0)
        rasterData(currentTrial).TGinRF = 0;
    % Else the trial was aborted
    else
        rasterData(currentTrial).TGinRF = 2;
    end
    
    % For loop that goes through all the channels
    for j = 1:length(unique_channels)
    
        % Load in the current trial
        currentChannel = unique_channels(j);
        
        % Get the data for the curent channel in this trial
        currentChannel_data = currentTrial_data(currentTrial_data(:,1)==currentChannel, :);
        
        % Get the unique units for this channel
        unique_units = unique(currentChannel_data(:,2));
        
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
    
end % End of currentTrial (i) for loop


 
% 
% % For loop that goes through each unique channel
% for i = 1:length(unique_channels)
%     
%     % Load in the currentChannel for easy handling
%     currentChannel = unique_channels(i);
%     
%     % Get the data of the current channel
%     currentChannel_data = data(data(:,1) == currentChannel, :);
%     
%     % Get the units in this channel (unique function sorts implicitly)
%     unique_units = unique(currentChannel_data(:,2));
%     
%     % For loop that goes through each unit in this channel
%     for j = 1:length(unique_units)
%         
%         % Load in the currentUnit for easy handling
%         currentUnit = unique_units(j);
%         
%         % Get the data of the current units
%         currentUnit_data = currentChannel_data(currentChannel_data(:,2) == currentUnit, :);
%         
%         % Concatenate the eCode data to the currentUnit data and sort by
%         % time (i.e. chronological order)
%         currentUnit_with_eCode_data = sortrows([currentUnit_data; eCode_data], 3);
%         
%         % Get the total spikes for this unit
%         currentUnit_totalSpikes = size(currentUnit_data, 1);
%         
%         % ---- This stuff below is from the individual
%         % extract_raster_data_RFtest.m file -------
%         
%         xRF = '';
%         yRF = '';
%         
%         % Find the indices of currentUnit data when the trial starts
%         currentUnit_trialStart_indices = find(currentUnit_with_eCode_data(:,2) == 1001); 
%         
%         % Preallocate the cell array to hold currentUnit trial data
%         currentUnit_trials_cellArray = cell(nTrials, 1);
%         
%         % Separate the trials and store each trial data in a cell array
%         % element
%         for k = 1:nTrials
%             
%             % Define the start and end indices for each trial
%             startIndex = currentUnit_trialStart_indices(k);
%             
%             % Define the end index depending on whether it is the last
%             % trial
%             if(k < nTrials)
%                 endIndex = currentUnit_trialStart_indices(k+1) - 1;
%             else
%                 endIndex = size(currentUnit_with_eCode_data, 1);
%             end
%             
%             % Store the trial data into a cell in the cell array
%             currentUnit_trials_cellArray{k,1} = currentUnit_with_eCode_data(startIndex:endIndex, :);
%             
%         end % For loop to make trials
%         
%     end % End of for loop that goes through each unit in this channel
%     
%     
%     
% end % End of for loop that goes through each unique channel





