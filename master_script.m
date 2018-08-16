% This script calls all the other scripts.
% This script is the control panel where you set all your parameters for
% the rest of the scripts.
%
% Pipeline: nev --> mat --> rasterData --> alignedData --> plot

% Clear the workspace
clear;

% Data switches
run_x1_nev_to_mat                = 0;
run_x2_mat_to_rasterData         = 1;
run_x3_rasterData_to_alignedData = 1;
run_x4_alignedData_to_plot       = 1;

%----------------------------------------------------%
%                  Parameters Begin                  %
%----------------------------------------------------%

% --------- x1_nev_to_mat --------- %

% Place the filename here without any extensions
filename = 'SP170126B';

% --------- x2_mat_to_rasterData --------- %

% Set the cell array of ecodes, fields, and entries for this specific
% experiment
% This is in the form {eCode, field, entry-for-eCode; ...}
eCodes_fields_entries = {...
    4000, 'ChoiceTarget', 'Left'; ...
    4001, 'ChoiceTarget', 'Right'; ...
    4100, 'Coherence', 50; ... % Coherences must be whole numbers
    4101, 'Coherence', 36; ...
    4102, 'Coherence', 24; ...
    4103, 'Coherence', 17; ...
    4104, 'Coherence', 10; ...
    4105, 'Coherence', 5; ...
    4106, 'Coherence', 0; ...
    7000, 'ChoiceTargetOn', 'time'; ...
    5000, 'GlassPatternCueOn', 'time'; ...
    1503, 'Saccade',  'time'; ...
    5050, 'Reward',  'time'; ...
    5001, 'Error_FP',  'time'; ...
    5004, 'Error_Tgt',  'time'; ...
    5005, 'Error_EarlySaccade',  'time'; ...
    5006, 'Error_ChoseDist',  'time'; ...
    5007, 'Error_NoSaccade',  'time' ...
};


% --------- x3_rasterData_to_alignedData --------- %

% If the field and the inputs match, then it is in the receptive field
toRF_parameters = {...
    'ChoiceTarget', 'Left'; ...
    'Reward', 'time' ...
};

% The buffer (in milliseconds) to place on both sides of the alignment data
% so that the atrifacts during smoothing do not appear in the areas of
% interest
alignmentBuffer = 100;

% The start and end timings for each of the plots
alignment_parameters = {
    'ChoiceTargetOn',    -200, 800;...
    'GlassPatternCueOn', -600, 600;...
    'Saccade',           -600, 600 ...
};

% The fields which if filled means an error
error_fields = {
    'Error_FP',...
    'Error_Tgt',...
    'Error_EarlySaccade',...
    'Error_ChoseDist',...
    'Error_NoSaccade',...
};

% Smoothing parameters
sigma = 0.01;


% --------- x4_alignedData_to_plot --------- %

% Cell array of RF fields to plot
RF_fields_to_plot = {'toRF', 'awayRF'}; % Default: {'toRF', 'awayRF'}

% The maximum y-value for the plots
yMax = 130;

% Save the figures
saveFigure = 1;



%----------------------------------------------------%
%                   Parameters End                   %
%----------------------------------------------------%



%----------------------------------------------------%
%                  Run Scripts Begin                 %
%----------------------------------------------------%

% Add the path to the function scripts and data files
addpath([pwd '/core_functions']);
addpath([pwd '/additional_functions']);
addpath([pwd '/data_files']);

% Run the scripts

% x1
if(run_x1_nev_to_mat)
   x1_nev_to_mat(filename);
end

% x2
if(run_x2_mat_to_rasterData)
   x2_mat_to_rasterData(filename, eCodes_fields_entries, toRF_parameters); 
end

% x3
if(run_x3_rasterData_to_alignedData)
   x3_rasterData_to_alignedData(filename, alignmentBuffer, alignment_parameters, error_fields, sigma); 
end

% x4
if(run_x4_alignedData_to_plot)
   x4_alignedData_to_plot(filename, alignmentBuffer, alignment_parameters, RF_fields_to_plot, yMax, saveFigure); 
end


%----------------------------------------------------%
%                   Run Scripts End                  %
%----------------------------------------------------%