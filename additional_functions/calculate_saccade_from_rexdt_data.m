clear;
% --- Passed in ---
filename = 'SP170126B';
run_rexdt = 0;
sigma_saccadeSmoothing = 0.001;
% The window used to calculate the acceleration
acceleration_window = 5;
velocity_window = 1;
timeBeforeSaccade = 50;
timeAfterSaccade = 100;
accelerationThreshold = 5000;

% Shorthands:
% vel = velocity
% acc = acceleration
% smo = smoothened
% uns = unsmoothened
% sac = saccade
% ard = around
% ver = vertical
% hor = horizontal

% ========================================================= %
% === PART 1/2: Get the _from_rexdt file from A&E files === %
% ========================================================= %

% If we want to run rexdt
if(run_rexdt)
    
    % Create a path to the rexdt function
    addpath([pwd '/rexdt']);
    
    % Run rexdt to get the from_rexdt.mat file
    rexdt([filename 'A']);
    
    % Delete the duplicate file from this folder (the actual one labeled iwth
    % _from_rexdt.mat is in the data_files folder
    delete([filename '.mat']);

end

% ================================================================= %
% === PART 2/2: Calculate the saccade from the _from_rexdt file === %
% ================================================================= %

% Load the file to this workspace
load([pwd '/../data_files/' filename '_from_rexdt.mat']);

% Create the kernel for smoothing
sigmaValues = -sigma_saccadeSmoothing*3:.001:sigma_saccadeSmoothing*3;
kernel = normpdf(sigmaValues, 0, sigma_saccadeSmoothing) * .001;
center = ceil(length(sigmaValues)/2); % What is this used for?

% The number of ms per trial in the eye position matrix
ms_positions = size(allh,2);



% Unsmoothened data (merely transferring variable names for easy readability)
all_vertical_positions   = allv;
all_horizontal_positions = allh;

% Calculate the velocities
all_vertical_velocity   = abs(...
                            all_vertical_positions(:,1+velocity_window:end) -...
                            all_vertical_positions(:,1:end-velocity_window)...
                          )/(velocity_window/1000);
all_horizontal_velocity = abs(...
                            all_horizontal_positions(:,1+velocity_window:end) -...
                            all_horizontal_positions(:,1:end-velocity_window)...
                          )/(velocity_window/1000);
all_diagonal_velocity = sqrt(...
                            (all_vertical_velocity.^2) +...
                            (all_horizontal_velocity.^2)...
                        );

% Calculate the accelerations
all_accelerations = abs(...
                      all_diagonal_velocity(:,1+acceleration_window:end) -...
                      all_diagonal_velocity(:,1:end-acceleration_window)...
                    )/(acceleration_window/1000);

% Get the logical matrix to index out the 1503 eCode times and get the
% column of the first instance
[dummyValue, col_1503] = find((allcodes == 1503), 1, 'first');
times_1503 = alltimes(:,col_1503);

% Below this line is old code
%----------------------------------------------------------

% For loop that goes through each trial to calculate the acceleration
for i = 1:rexnumtrials
    
    % Smoothing the data for this trial
    % (Vertical and horizontal eye positions)
    vertical_smoothened   = conv(allv(i,:),kernel);
    horizontal_smoothened = conv(allh(i,:),kernel);
    
    % Prepare for trimming
    startIndex = ((length(vertical_smoothened)-ms_positions)/2) + 1;
    % ^ +1 because don't include the first index to match the length of the 
    % original ms once it is paired with endIndex
    endIndex = startIndex + ms_positions - 1;
    % ^ -1 because we want to rid of the +1 before
    
    % Trim the smoothened data and add it to the matrix
    all_vertical_smoothened(i,:)   = vertical_smoothened(1, startIndex:endIndex);
    all_horizontal_smoothened(i,:) = horizontal_smoothened(1, startIndex:endIndex);
    
    % Add it to the matrix
    
    % Unsmoothened data (merely transferring variable names for easy readability)
    all_vertical_unsmoothened(i,:)   = allv(i,:);
    all_horizontal_unsmoothened(i,:) = allh(i,:);
        
    % ------------------------------ %
    % --- Calculate the velocity --- %
    % ------------------------------ %
    
    % For loop that goes through each ms of the position arrays except the last one
    for j = 1:(ms_positions-1)
        
        %  --- Smoothened ---
        
        % Vertical velocity
        position1 = all_vertical_smoothened(i,j);   % Position of the eye at ms
        position2 = all_vertical_smoothened(i,j+1); % Position of the eye at ms+1
        current_velocity_vertical = abs(position2 - position1)/(1/1000); % Difference in position *200? (200 implies that the time difference between each cell is 5ms)
        velocity_vertical_smoothened(i,j) = current_velocity_vertical; % Store the velocity
        
        
        % Horizontal velocity
        position1 = all_horizontal_smoothened(i,j);   % Position of the eye at ms
        position2 = all_horizontal_smoothened(i,j+1); % Position of the eye at ms+1
        current_velocity_horizontal = abs(position2 - position1)/(1/1000); % Difference in position *200?
        velocity_horizontal_smoothened(i,j) = current_velocity_horizontal;  % Store the velocity
        
        % Diagonal velocity
        velocity_diagonal_smoothened(i,j)= sqrt((current_velocity_vertical^2) + (current_velocity_horizontal^2));
        
        
    end % End of for loop that goes through each ms of the position arrays (j)
    
    
    % ---------------------------------- %
    % --- Calculate the acceleration --- %
    % ---------------------------------- %
    
    % The number of ms per trial in the velocity matrix
    ms_velocity = size(allh, 2);
    
    % For loop that goes through each ms of the velocity arrays except the last window size + 1
    for j = 1:(ms_velocity - acceleration_window - 1) % -1 because we have 1 less ms after calculating acceleration from velocity
        
        %  --- Smoothened ---
        
        velocity1 = velocity_diagonal_smoothened(i,j);        % Velocity at ms
        velocity2 = velocity_diagonal_smoothened(i,j+acceleration_window); % Velocity at ms + window
        current_acceleration = abs(velocity2 - velocity1)/(acceleration_window/1000); % Difference in velocity/time window
        acceleration_smoothened(i,j) = current_acceleration; % Store the acceleration
        
        
    end % End of for loop that goes through each ms of the velocity arrays (j)

end % End of for loop that goes through each trial (i)


% Get the indices where eCode is 1503 (the code for saccade)
% The saccade eCode is used as a reference point
[rows_1503, cols_1503] = find(allcodes == 1503);
col_1503 = cols_1503(1); % col is constant throughout

% For loop that runs for each saccade (eCode 1503)
% Trials without saccade eCodes are skipped
for i = 1:max(rows_1503)
    
    % Get the current trial
    currentTrial = i;
    
    % If this trial had a saccade, then proceed to get the time around the
    % saccade
    if(ismember(currentTrial, rows_1503))
        
        % Get the saccade time
        saccade_eCode_time(currentTrial) = alltimes(currentTrial, col_1503);

        %  --- Smoothened ---
        
        disp(currentTrial);

        % Get the velocity around the saccade
        velocity_around_saccade_smoothened(currentTrial,:) = ...
            velocity_diagonal_smoothened(currentTrial,...
                (saccade_eCode_time(currentTrial) - timeBeforeSaccade):(saccade_eCode_time(currentTrial) + timeAfterSaccade));
        % Get the acceleration around the saccade
        acceleration_around_saccade_smoothened(currentTrial,:) = ...
            acceleration_smoothened(currentTrial,...
                (saccade_eCode_time(currentTrial) - timeBeforeSaccade):(saccade_eCode_time(currentTrial) + timeAfterSaccade));

    % Else fill it in with NaNs
    else
        
        % Fill in all variables with NaNs
        saccade_eCode_time(currentTrial) = nan;
        
        velocity_around_saccade_smoothened(currentTrial,:)       = nan(1, timeAfterSaccade + timeBeforeSaccade + 1);
        acceleration_around_saccade_smoothened(currentTrial,:)   = nan(1, timeAfterSaccade + timeBeforeSaccade + 1);
        velocity_around_saccade_unsmoothened(currentTrial,:)     = nan(1, timeAfterSaccade + timeBeforeSaccade + 1);
        acceleration_around_saccade_unsmoothened(currentTrial,:) = nan(1, timeAfterSaccade + timeBeforeSaccade + 1);
        
    end % End of if(ismember(currentTrial, rows_1503))
    
    
end % End of for loop that runs for each saccade (i)
        
%  --- Smoothened ---

% Replace the accelerations below the threshold with NaN
cells_above_threshold = acceleration_smoothened > accelerationThreshold; % Logical matrix
acceleration_thresholded_smoothened = nan(size(acceleration_smoothened));
acceleration_thresholded_smoothened(cells_above_threshold) = acceleration_smoothened(cells_above_threshold);

% Find the first instance of a saccade for each trial (row)
logical_index = acceleration_around_saccade_smoothened > accelerationThreshold;
first_index_logical = (cumsum(logical_index,2) == 1) & logical_index; % Only the first element that crosses the threshold is 1
first_saccade_time_smoothened = sum(first_index_logical.*acceleration_around_saccade_smoothened, 2); % Only the first element that crosses threshold is multiplied by 1, others are mulitplied by 0

    
    
    
    










