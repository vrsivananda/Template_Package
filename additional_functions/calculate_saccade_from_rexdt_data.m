clear;
% Passed in
filename = 'SP170126B';
sigma_saccadeSmoothing = 0.001;
% The window used to calculate the acceleration
window = 5;
timeBeforeSaccade = 50;
timeBeforeSaccade = 100;
accelerationThreshold = 5000;

% ========================================================= %
% === PART 1/2: Get the _from_rexdt file from A&E files === %
% ========================================================= %


% Create a path to the rexdt function
addpath([pwd '/rexdt']);

% Run rexdt to get the from_rexdt.mat file
%rexdt([filename 'A']);

% Delete the duplicate file from this folder (the actual one labeled iwth
% _from_rexdt.mat is in the data_files folder
%delete([filename '.mat']);

% Load the file to this workspace
load([pwd '/../data_files/' filename '_from_rexdt.mat']);

% ================================================================= %
% === PART 2/2: Calculate the saccade from the _from_rexdt file === %
% ================================================================= %

% Create the kernel for smoothing
sigmaValues = -sigma_saccadeSmoothing*3:.001:sigma_saccadeSmoothing*3;
kernel = normpdf(sigmaValues, 0, sigma_saccadeSmoothing) * .001;
center = ceil(length(sigmaValues)/2); % What is this used for?

% The number of ms per trial in the eye position matrix
ms_position = size(allh,2);

% For loop that goes through each trial to calculate the acceleration
for i = 1:rexnumtrials
    
    % Smoothing the data for this trial
    % (Vertical and horizontal eye positions)
    vertical_smoothened   = conv(allv(i,:),kernel);
    horizontal_smoothened = conv(allh(i,:),kernel);
    
    % Prepare for trimming
    startIndex = ((length(vertical_smoothened)-ms_position)/2) + 1;
    % ^ +1 because don't include the first index to match the length of the 
    % original ms once it is paired with endIndex
    endIndex = startIndex + ms_position - 1;
    % ^ -1 because we want to rid of the +1 before
    
    % Trim the smoothened data and add it to the matrix
    all_vertical_smoothened(i,:)   = vertical_smoothened(1, startIndex:endIndex);
    all_horizontal_smoothened(i,:) = horizontal_smoothened(1, startIndex:endIndex);
    
    % Add it to the matrix
    
    % Unsmoothened data (transferring variable names)
    all_vertical_unsmoothened(i,:)   = allv(i,:);
    all_horizontal_unsmoothened(i,:) = allh(i,:);
        
    % ------------------------------ %
    % --- Calculate the velocity --- %
    % ------------------------------ %
    
    % For loop that goes through each ms of the position arrays except the last one
    for j = 1:(ms_position-1)
        
        %  --- Smoothened ---
        
        % Vertical velocity
        position1 = all_vertical_smoothened(i,j);   % Position of the eye at ms
        position2 = all_vertical_smoothened(i,j+1); % Position of the eye at ms+1
        current_velocity_vertical = abs(position2 - position1) * 200; % Difference in position *200?
        velocity_vertical_smoothened(i,j) = current_velocity_vertical; % Store the velocity
        
        
        % Horizontal velocity
        position1 = all_horizontal_smoothened(i,j);   % Position of the eye at ms
        position2 = all_horizontal_smoothened(i,j+1); % Position of the eye at ms+1
        current_velocity_horizontal = abs(position2 - position1) * 200; % Difference in position *200?
        velocity_horizontal_smoothened(i,j) = current_velocity_horizontal;  % Store the velocity
        
        % Diagonal velocity
        velocity_diagonal_smoothened(i,j)= sqrt((current_velocity_vertical^2) + (current_velocity_horizontal^2));
        
        
        %  --- Unsmoothened ---
        
        % Vertical velocity
        position1 = all_vertical_unsmoothened(i,j);   % Position of the eye at ms
        position2 = all_vertical_unsmoothened(i,j+1); % Position of the eye at ms+1
        current_velocity_vertical_ = abs(position2 - position1) * 200; % Difference in position *200?
        velocity_vertical_smoothened(i,j) = current_velocity_vertical; % Store the velocity
        
        
        % Horizontal velocity
        position1 = all_horizontal_unsmoothened(i,j);   % Position of the eye at ms
        position2 = all_horizontal_unsmoothened(i,j+1); % Position of the eye at ms+1
        current_velocity_horizontal = abs(position2 - position1) * 200; % Difference in position *200?
        velocity_horizontal_unsmoothened(i,j) = current_velocity_horizontal;  % Store the velocity
        
        % Diagonal velocity
        velocity_diagonal_unsmoothened(i,j)= sqrt((current_velocity_vertical^2) + (current_velocity_horizontal^2));
        
    end % End of for loop that goes through each ms of the position arrays (j)
    
    
    % ---------------------------------- %
    % --- Calculate the acceleration --- %
    % ---------------------------------- %
    
    % The number of ms per trial in the velocity matrix
    ms_velocity = size(allh,2);
    
    % For loop that goes through each ms of the velocity arrays except the last one
    for j = 1:(ms_velocity - window - 1) % -1 because we have 1 less ms after calculating acceleration from velocity
        
        %  --- Smoothened ---
        
        velocity1 = velocity_diagonal_smoothened(i,j);        % Velocity at ms
        velocity2 = velocity_diagonal_smoothened(i,j+window); % Velocity at ms + window
        current_acceleration = abs(velocity2 - velocity1)/(window/1000); % Difference in velocity/time window
        acceleration_smoothened(i,j) = current_acceleration; % Store the acceleration
        
        %  --- Unsmoothened ---
        
        velocity1 = velocity_diagonal_unsmoothened(i,j);        % Velocity at ms
        velocity2 = velocity_diagonal_unsmoothened(i,j+window); % Velocity at ms + window
        current_acceleration = abs(velocity2 - velocity1)/(window/1000); % Difference in velocity/time window
        acceleration_unsmoothened(i,j) = current_acceleration; % Store the acceleration
        
    end % End of for loop that goes through each ms of the velocity arrays (j)

end % End of for loop that goes through each trial (i)


% Get the indices where eCode is 1503 (the code for saccade)
% The saccade eCode is used as a reference point
[rows_1503, cols_1503] = find (allcodes ==1503);

% For loop that runs for each saccade (eCode 1503)
for i = 1:length(rows_1503)
    
    % Get the saccade time
    saccade_eCode_time(i) = alltimes(rows_1503(i), cols_1503(i));
        
    %  --- Smoothened ---
    
    % Get the velocity around the saccade
    velocity_around_saccade_smoothened(i,:) = ...
        velocity_diagonal_smoothened(rows_1503(i),...
            (saccade_eCode_time(i) - timeBeforeSaccade):(saccade_eCode_time(i) + timeAfterSaccade));
    % Get the acceleration around the saccade
    acceleration_around_saccade_smoothened(i,:) = ...
        acceleration_smoothened(rows_1503(i),...
            (saccade_eCode_time(i) - timeBeforeSaccade):(saccade_eCode_time(i) + timeAfterSaccade));
        
    %  --- Unsmoothened ---
    
    % Get the velocity around the saccade
    velocity_around_saccade_unsmoothened(i,:) = ...
        velocity_diagonal_unsmoothened(rows_1503(i),...
            (saccade_eCode_time(i) - timeBeforeSaccade):(saccade_eCode_time(i) + timeAfterSaccade));
    % Get the acceleration around the saccade
    acceleration_around_saccade_unsmoothened(i,:) = ...
        acceleration_unsmoothened(rows_1503(i),...
            (saccade_eCode_time(i) - timeBeforeSaccade):(saccade_eCode_time(i) + timeAfterSaccade));
    
    
end % End of for loop that runs for each saccade (i)
