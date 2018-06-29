% This file takes in the rasterData and processes it to be ready to be
% plotted


% Clear the workspace
clear;

%----------------------------------%
%------ Set parameters begin ------%
%----------------------------------%

% Set the filename
filename = 'SP170126R';

% The start and end timings for each of the plots
alignment_parameters = {
    'ChoiceTargetOn',    -200, 800,...
    'GlassPatternCueOn', -600, 600,...
    'Saccade',           -600, 300 ...
};

%----------------------------------%
%------- Set parameters end -------%
%----------------------------------%

% Set the filePath
filePath = [pwd '/../data_files/' filename '_alignedData.mat'];

% Load the data
dataStructure = load(filePath);
alignedData = dataStructure.alignedData;

% Create the path to the tight_subplot function
addpath([pwd '/../additional_functions/subplot_tight/subplot_tight']);

% ---------- Plot the figure ----------

% New figure
figure;

% Get the alignmentFields
alignmentFields = fieldnames(alignedData);

% For loop that goes through each alignmentField (each subplot)
for i = 1:numel(alignmentFields)
    
    % Prep the subplot
    subplot_tight(1,numel(alignmentFields),i);
    
    % Load in the alignmentField
    alignmentField = alignmentFields{i};
    
    % Get the coherences
    coherences = fieldnames(alignedData.(alignmentField));
    
    % For loop that goes through each coherence
    for j = 1:numel(coherences)
        
        % Get the current coherence
        currentCoherence = coherences{j};
        
        % Calculate the plotting color for the current coherence
        coherenceColor = repmat(((j/(numel(coherences))*0.5)), 1, 3);
        
        % Get the alignmentStart value
        alignmentStart = alignedData.(alignmentField).(currentCoherence).alignmentStart;
        
        % Create an RF_array to loop through
        RF_array = {'inRF', 'notInRF'};
        
        % For loop that goes through each RF
        for k = 1:numel(RF_array)
            
            % Get the current RF
            currentRF = RF_array{k};
            
            % Determine the lineStyle depending on inRF or not
            if(strcmp(currentRF, 'inRF'))
               lineStyle =  '-';
            elseif(strcmp(currentRF, 'notInRF'))
                lineStyle = '--';
            end
            
            % Get the average summed convolution data
            avg_summed_conv = alignedData.(alignmentField).(currentCoherence).(currentRF).avg_summed_conv;
            
            % Set the x-range
            xRange = alignmentStart:(alignmentStart + length(avg_summed_conv) - 1);
            
            % Plot the data
            plot(xRange, avg_summed_conv, 'linestyle', lineStyle, 'Color', coherenceColor,'linewidth',2);
            hold on;
            
            % Plot the vertical line
            plot([0, 0], [0, 3],'k--', 'linewidth', 1);
            hold on;
            
            title(alignmentField);
            set(gca,'FontSize',12)
            xlim([xRange(1), xRange(end)]);
            ylim([0 3])
            
            % Only for first plot
            if(i == 1)
                ylabel ('Firing rates (spikes / sec)');
            % Only for second plot
            elseif(i == 2)
                xlabel ('time (msec)');
            end
            
        end % End of RF for loop (k)
        
    end % End of coherences for loop (j)
    
end % End of alignmentField (subplot) for loop (i)
