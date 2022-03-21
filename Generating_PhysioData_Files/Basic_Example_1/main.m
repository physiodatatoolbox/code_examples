%--------------------------------------------------------------------------
% INFO:
%  This file shows how to load signals from a tsv file into MATLAB and save
%  them as a PhysioData file for processing in the Toolbox, along with
%  custom labels and epochs.
%  
%  https://physiodatatoolbox.leidenuniv.nl/
%--------------------------------------------------------------------------


%% Loading Raw Data:

% Load data:
rawFilename = '.\data\ecg_eda.tsv';
rawData = readtable(rawFilename ...
    , 'FileType', 'text' ...
    , 'Delimiter', '\t');

% The data consists of two columns: ECG and EDA. The raw data does not
% contain headers though, so lets manually rename the table variables:
rawData = renamevars(rawData, {'Var1' 'Var2'},  {'ECG' 'EDA'});

% Create an empty data struct. This will represent the physioData file:
pdtData = struct();

% Add the ECG signal to the struct in channel 1:
chanNum = 1;
pdtData.data.signals.channels{chanNum}            = rawData.ECG;
pdtData.data.signals.channelNames{chanNum}        = 'ECG';
pdtData.data.signals.channelUnits{chanNum}        = 'mV';
pdtData.data.signals.channelDescription{chanNum}  = 'ECG data';

% Add the EDA signal to the struct in channel 2:
chanNum = 2;
pdtData.data.signals.channels{chanNum}            = rawData.EDA;
pdtData.data.signals.channelNames{chanNum}        = 'EDA';
pdtData.data.signals.channelUnits{chanNum}        = 'uS';
pdtData.data.signals.channelDescription{chanNum}  = 'EDA data';

% Log that the sampling frequency was 1000 Hz:
pdtData.data.signals.fs = 1000;


%% Adding Labels:
% Labels are events that can be referenced by the Toolbox in order to
% generate epochs. Labels need a timestamp (in seconds) and a value.

% Let's say we want to add 3 events in the file:
%    # A label at 30 seconds with the value 'Start Baseline'.
%    # A label at 60 seconds with the value 'End Baseline'.
%    # A label at 70 seconds with the value 'Participant ready'.
% First, for ease, define the labels in a cell array with the times in
% seconds in the first column, and the values as chars in the second:
labels = {...
    ...
    30   'Start Baseline'   ; ...
    60   'End Baseline'   ; ...
    70   'Participant ready'   ; ...
    };

% Now, reformat the cell array to conform to the file spec and add it to
% the data struct:
pdtData.data.labels.t               = vertcat(labels{:,1});
pdtData.data.labels.channels{1}     = labels(:,2);
pdtData.data.labels.channelUnits{1} = '-';
pdtData.data.labels.channelNames{1} = 'Labels';


%% Adding Pregenerated Epochs:
% A physioData file can also contain pregenerated epochs (time segments).
% These time segments will automatically be loaded into the Toolbox and
% analyzed. The pregenerated epochs must have a start time (startTime) an
% end time (endTime) and a name (epochName). Additionally, extra metadata
% can be added(e.g. we use 'condition' and 'group' here).

% Let's say we want to add 4 epochs to the file:
%    # 'Trial 1' from 80  to 95  seconds, with the condition 'A'.
%    # 'Trial 2' from 100 to 115 seconds, with the condition 'B'.
%    # 'Trial 3' from 120 to 135 seconds, with the condition 'A'.
%    # 'Trial 4' from 140 to 155 seconds, with the condition 'B'.
% All epochs for this file will have a 'group' value of 1. Again, for ease,
% first define a cell array with the epoch data:
epochData = {...
    'epochName'  'startTime'  'endTime'  'condition'  'group'  ;...
    'Trial 1'     80           95        'A'           1       ;...
    'Trial 2'     100          115       'B'           1       ;...
    'Trial 3'     120          135       'A'           1       ;...
    'Trial 4'     140          155       'B'           1       ;...
    };

% Generate a table from the cell array and save it to the data struct as
% per the file spec:
pdtData.epochs.epochData ...
    = cell2table(epochData(2:end, :), 'VariableNames', epochData(1, :));


%% Saving the File:

% Before saving, add some metadata to the file (optional):
pdtData.physioDataInfo.rawDataSource       = rawFilename;
pdtData.physioDataInfo.pdtFileCreationDate = datestr(now);
pdtData.physioDataInfo.pdtFileCreationUser = getenv('USERNAME');

% Save contents of the data struct (pdtData) to a physioData file:
[~, pdtFilebasename, ~] = fileparts(rawFilename);
save(['.\data\' pdtFilebasename '.physioData'] ...
    , '-struct', 'pdtData');