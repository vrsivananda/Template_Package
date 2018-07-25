function x4_alignedData_to_plot(filename, alignmentBuffer, alignment_parameters)

    % This file takes in the rasterData and processes it to be ready to be
    % plotted

    % Set the filePath
    filePath = [pwd '/data_files/' filename '_alignedData.mat'];

    % Load the data
    dataStructure = load(filePath);
    alignedData = dataStructure.alignedData;

    % Create the path to the tight_subplot function
    addpath([pwd '/additional_functions/subplot_tight']);

    % ---------- Plot the figure ----------
    
    % Get the neurons
    neurons = fieldnames(alignedData);

    % For loop that goes through each neuron (each neuron is a
    % separate plot)
    for i = 1:length(neurons)

        % New figure
        figure;
        
        % Get the current neuron
        currentNeuron = neurons{i};
        
        disp('-----------New figure-----------');
        disp(['Neuron: ' currentNeuron]);
        
        % For loop that goes through each alignment field
        for j = 1:size(alignment_parameters,1) 
        
            % Get the current alignment field
            alignmentField = alignment_parameters{j,1};
            disp(['alignmentField: ' alignmentField]);
            
            % Get the alignment start and end parameter
            alignmentStart = alignment_parameters{j,2};
            alignmentEnd = alignment_parameters{j,3};    

            % Prep the subplot
            subplot_tight(1,numel(alignment_parameters)/3,j);
            
            % Create cell array of RF fields to loop through
            RF_fields = {'inRF', 'notInRF'};
            
            % For loop that goes through each RF field
            for k = 1:length(RF_fields)
                
                % Get the current RF field
                RF_field = RF_fields{k};
                disp(['RF_field: ' RF_field]);

                % Determine the lineStyle depending on inRF or not
                if(strcmp(RF_field, 'inRF'))
                   lineStyle =  '-';
                elseif(strcmp(RF_field, 'notInRF'))
                    lineStyle = '--';
                end
                
                % Get the list of coherences in a cell array
                coherences = fieldnames(alignedData.(currentNeuron).(alignmentField).(RF_field));
                
                % For loop that goes through each coherence field
                for l = 1:length(coherences)
                    
                    % Get the current coherence
                    currentCoherence = coherences{l};
                    disp(['currentCoherence: ' currentCoherence]);

                    % Calculate the plotting color for the current coherence
                    coherenceColor = repmat(((l/(length(coherences))*0.5)), 1, 3);
                    
                    % Get the data to plot
                    summedConvolutions = alignedData.(currentNeuron).(alignmentField).(RF_field).(currentCoherence).summedConvolutions;
                    
                    % Truncate each end to remove the buffer and get the relevant data
                    y = summedConvolutions(alignmentBuffer+1:length(summedConvolutions)-alignmentBuffer);
                    
                    % Make the x-axis
                    xRange = alignmentStart:alignmentEnd;

                    % Plot the data
                    plot(xRange, y, 'linestyle', lineStyle, 'Color', coherenceColor,'linewidth',2);
                    hold on;

                    % Plot the vertical line
                    plot([0, 0], [0, 100],'k--', 'linewidth', 1);
                    hold on;

                    title(alignmentField);
                    set(gca,'FontSize',12)
                    xlim([xRange(1), xRange(end)]);
                    ylim([0 100])

                    % Only for first subplot
                    if(j == 1)
                        ylabel ('Firing rates (spikes / sec)');
                    % Only for second subplot
                    elseif(j == 2)
                        xlabel ('time (msec)');
                    end

                    
                end % End of for loop that goes through each coherence (l)
                
            end % End of for loop that goes through RF field (k)
            
        end % End of for loop that goes through each alignment field
        
    end % End of for loop that goes through each neuron (i)
    
end % End of function
