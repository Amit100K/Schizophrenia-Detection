%% To load .eea files and make a single .mat file
% for healthy subjects=================================================
eegDirectory = 'location where the files are stored';
% Initialize a cell array to store EEG data
eegData = cell(1, "number of HC files"); 
% Loop through the EEG files and load them
for i = 1:"number of HC files"
    % Construct the file name
    eegFileName = sprintf('Healthy (%d).eea', i);
    % Check if the file exists
    fullFilePath = fullfile(eegDirectory, eegFileName);
    if exist(fullFilePath, 'file')
        % Open the file
        fid = fopen(fullFilePath, 'r');
        % Load the EEG data from the current file using fscanf
        eegData{i} = fscanf(fid, '%f'); 
        % Close the file
        fclose(fid);
    else
        fprintf('File %s does not exist.\n', eegFileName);
    end
end
Healthy_data = cat(2, eegData{:});
Healthy_data = Healthy_data';

% for SZ subjects:
% ==========================================================
% Specify the directory where your EEG files are located
eegDirectory = 'location where the files are stored';
% Initialize a cell array to store EEG data
eegData = cell(1, "number of SZ EEG files"); 
% Loop through the EEG files and load them
for i = 1:"number of SZ EEG files"
    % Construct the file name
    eegFileName = sprintf('SZ (%d).eea', i);
    % Check if the file exists
    fullFilePath = fullfile(eegDirectory, eegFileName);
    if exist(fullFilePath, 'file')
        % Open the file
        fid = fopen(fullFilePath, 'r');
        % Load the EEG data from the current file using fscanf
        eegData{i} = fscanf(fid, '%f'); 
        % Close the file
        fclose(fid);
    else
        fprintf('File %s does not exist.\n', eegFileName);
    end
end
% Combine EEG data into a single matrix (if applicable)
SZ_data = cat(2, eegData{:});
SZ_data = SZ_data';
%% As in the dataset B, All the channel of a perticular subject given in a single matrix so we hvae to separate out each and every subjects EEG

% For HC:====================================================
num_signals = size(Healthy_data, 1);
segment_length = 7680; % 60 seconds
% Initialize a cell array to store the segmented signals
HLT = cell(num_signals, 1);
% Segment each signal
for i = 1:num_signals
    signal = Healthy_data(i, :); % Get the i-th signal
    % Calculate the number of segments for this signal
    num_segments = numel(signal) / segment_length;
    % Reshape the signal into segments
    segments = reshape(signal, segment_length, num_segments)';
    % Store the segments in the cell array
    HLT{i} = segments;
end

%for SZ =====================================================
num_signals = size(SZ_data, 1);
segment_length = 7680; % 60 seconds
% Initialize a cell array to store the segmented signals
SZ = cell(num_signals, 1);
% Segment each signal
for i = 1:num_signals
    signal = SZ_data(i, :); % Get the i-th signal
    % Calculate the number of segments for this signal
    num_segments = numel(signal) / segment_length;
    % Reshape the signal into segments
    segments = reshape(signal, segment_length, num_segments)';
    % Store the segments in the cell array
    SZ{i} = segments;
end
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++SEGMENTATION ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% For SZ: 2-seconds segmentation ===========================================
% Define the number of samples you want to select (for 1 second 128 samples, for 2 seconds 256 samples and so on)
num_samples_to_select = 256;
% Calculate the number of iterations needed to cover all samples
num_iterations = ceil(7680 / num_samples_to_select);
% Create a new cell array to store the selected samples
selected_samples_SZ = cell(size(SZ));
for i = 1:numel(SZ)
    current_data = SZ{i};
    selected_data = cell(1, num_iterations);
    for j = 1:num_iterations
        start_index = (j - 1) * num_samples_to_select + 1;
        end_index = min(j * num_samples_to_select, 7680); 
        selected_data{j} = current_data(:, start_index:end_index);
    end
    selected_samples_SZ{i} = selected_data;
end

% for HC: 2-seconds segmentation ============================================================ 
num_samples_to_select = 256;
num_iterations = ceil(7680 / num_samples_to_select);
selected_samples_HLT = cell(size(HLT));
for i = 1:numel(HLT)
    current_data = HLT{i};
    selected_data = cell(1, num_iterations);

    for j = 1:num_iterations
        start_index = (j - 1) * num_samples_to_select + 1;
        end_index = min(j * num_samples_to_select, 7680); 
        selected_data{j} = current_data(:, start_index:end_index);
    end
    selected_samples_HLT{i} = selected_data;
end

% Reshaping =======================HC===================================
a = [];
for i = 1:"number of inner cells of selected_samples_HLT" % in my case it was 30
    for j = 1:"number of HC subjects" % outer cell siz, 39 for HC
        a = [a; selected_samples_HLT{j,1}{1,i}];
    end
end
rows_per_cell = "number of channels"; % 16 for dataset B
num_cells = ceil(size(a, 1) / rows_per_cell);
cell_array_HLT = cell(num_cells, 1);
for i = 1:num_cells
    start_row = (i - 1) * rows_per_cell + 1;
    end_row = min(i * rows_per_cell, size(a, 1));
    cell_array_HLT{i} = a(start_row:end_row, :);
end
% Reshaping =====================SZ======================================
b = [];
for i = 1:"number of inner cells of selected_samples_SZ" % in my case it was 30
    for j = 1:"number of SZ subjects" % outer cell siz, 45 for SZ
        b = [b; selected_samples_SZ{j,1}{1,i}];
    end
end
rows_per_cell = "number of channels"; % 16 for dataset B
num_cells = ceil(size(b, 1) / rows_per_cell);
cell_array_SZ = cell(num_cells, 1);
for i = 1:num_cells
    start_row = (i - 1) * rows_per_cell + 1;
    end_row = min(i * rows_per_cell, size(b, 1));
    cell_array_SZ{i} = b(start_row:end_row, :);
end

%% +++++++++++++++++++++++++++++++++++++++++++++ Emperical Wavelet Transform ++++++++++++++++++++++++++++++++++++++
% Rhythem for SZ
ch = "number of channels";
fs = "sampling rate";
num_cells = numel(cell_array_SZ);
num_channels = ch;
EWT_results_SZ = cell(num_cells, 1);
for i = 1:num_cells
    channel_results = cell(num_channels, 1);
    for j = 1:num_channels
        channel_data = cell_array_SZ{i, 1}(j, :);
        [ewt,mfb,boundaries,ff] = EWT1Duse(channel_data', fs);
        reconstructed_IMFs = EWT_Modes_EWT1D(ewt, mfb);
        channel_results{j} = reconstructed_IMFs;
    end
    EWT_results_SZ{i} = channel_results;
end
% Rhythem for HC
num_cells = numel(cell_array_HLT);
EWT_results_HLT = cell(num_cells, 1);
for i = 1:num_cells
    channel_results = cell(num_channels, 1);
    for j = 1:num_channels
        channel_data = cell_array_HLT{i, 1}(j, :);
        [ewt,mfb,boundaries,ff] = EWT1Duse(channel_data', fs);
        reconstructed_IMFs = EWT_Modes_EWT1D(ewt, mfb);
        channel_results{j} = reconstructed_IMFs;
    end
    EWT_results_HLT{i} = channel_results;
end

% Rearrangement of data for SZ =============================================
for j = 1:numel(EWT_results_SZ)
    for k = 1:"number of channels"
            new_Data{j}{k} = [EWT_results_SZ{j, 1}{k, 1}{1, 1} EWT_results_SZ{j, 1}{k, 1}{2, 1} EWT_results_SZ{j, 1}{k, 1}{3, 1} EWT_results_SZ{j, 1}{k, 1}{4, 1} EWT_results_SZ{j, 1}{k, 1}{5, 1}];
        end
end
% Preallocate data_SZ cell array
Data_SZ = cell(1, numel(EWT_results_SZ));
for i = 1:numel(EWT_results_SZ)
Data_SZ{i} = [new_Data{1, i}{1, 1} new_Data{1, i}{1, 2} new_Data{1, i}{1, 3} new_Data{1, i}{1, 4} new_Data{1, i}{1, 5} new_Data{1, i}{1, 6} new_Data{1, i}{1, 7} new_Data{1, i}{1, 8} new_Data{1, i}{1, 9} new_Data{1, i}{1, 10} new_Data{1, i}{1, 11} new_Data{1, i}{1, 12} new_Data{1, i}{1, 13} new_Data{1, i}{1, 14} new_Data{1, i}{1, 15} new_Data{1, i}{1, 16}];
end

% Rearrangement of data for HC ============================================
for j = 1:numel(EWT_results_HLT)
    for k = 1:"number of channels"
            Data{j}{k} = [EWT_results_HLT{j, 1}{k, 1}{1, 1} EWT_results_HLT{j, 1}{k, 1}{2, 1} EWT_results_HLT{j, 1}{k, 1}{3, 1} EWT_results_HLT{j, 1}{k, 1}{4, 1} EWT_results_HLT{j, 1}{k, 1}{5, 1}];
    end
end
% Preallocate data_SZ cell array
Data_HLT = cell(1, numel(EWT_results_HLT));
for i = 1:numel(EWT_results_HLT)
    Data_HLT{i} = [Data{1, i}{1, 1} Data{1, i}{1, 2} Data{1, i}{1, 3} Data{1, i}{1, 4} Data{1, i}{1, 5} Data{1, i}{1, 6} Data{1, i}{1, 7} Data{1, i}{1, 8} Data{1, i}{1, 9} Data{1, i}{1, 10} Data{1, i}{1, 11} Data{1, i}{1, 12} Data{1, i}{1, 13} Data{1, i}{1, 14} Data{1, i}{1, 15} Data{1, i}{1, 16}];
end
Data_SZ = Data_SZ';
Data_HLT = Data_HLT';
Data_SZ_transposed = cellfun(@transpose, Data_SZ, 'UniformOutput', false);
Data_HLT_transposed = cellfun(@transpose, Data_HLT, 'UniformOutput', false)
% Create combined matrix by vertically concatenating the matrices
combined_matrix = [Data_SZ_transposed; Data_HLT_transposed];
combined_matrix = transpose(combined_matrix);
% Create categorical labels for the categories (SZ and HLT)
sz_labels = categorical(repmat("SZ", size(Data_SZ, 1), 1), ["SZ", "HC"]);
hlt_labels = categorical(repmat("HC", size(Data_HLT, 1), 1), ["SZ", "HC"]);
% Combine the labels
combined_labels = [sz_labels; hlt_labels];

%% +++++++++++++++++++++++++++++++++++Wavelet Scattering Transform++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
N = 256;
fs = "sampling rate";
sn = waveletScattering('SignalLength',N,...
    'SamplingFrequency',fs,...
    'QualityFactors',[4 2 1], 'OptimizePath',true);
[~,numpaths] = paths(sn);
Ncfs = numCoefficients(sn);
sum(numpaths)
Final_Data = cell(1, numel(combined_matrix));
for i = 1:numel(combined_matrix)
    Final_Data{i} = cell(1, 80);
    for j = 1:80
        Final_Data{i}{j} = featureMatrix(sn, combined_matrix{1, i}(j, :));
    end
end
Final_Data = Final_Data';

for i =1:numel(Final_Data)
    Data{i} = (Final_Data{i, 1})' ; 
end
% to reshape and readjust Final Data 
for j =1:numel(Final_Data)
    new_Data{j} = cat(2, Data{1, j}{1:80});
end
for i =1:numel(Final_Data)
    Final_Data{i} = (new_Data{1, i}) ;
end
[trainData, testData, trainLabels, testLabels] = partition_DATA1(80, Final_Data, combined_labels);

%% ++++++++++++++++++++++++++++++++++++++++++++++LSTM-based Deep Neural Network+++++++++++++++++++++++++++++++++++++++++++++++
miniBatchSize = 64;
inputSize = sum(numpaths);
numHiddenUnits = 800;
numClasses = 2;
layers = [ ...
    sequenceInputLayer(inputSize)
    lstmLayer(numHiddenUnits,OutputMode="last")
    dropoutLayer(0.4)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer]
options = trainingOptions("adam", ...
    ExecutionEnvironment="auto", ...
    GradientThreshold=1, ...
    MaxEpochs=100, ...
    InitialLearnRate=0.00066, ...
    MiniBatchSize=miniBatchSize, ...
    L2Regularization=0.001, ...
    SequenceLength="longest", ...
    Shuffle="never", ...
    Verbose=0, ...
    Plots="training-progress");
net = trainNetwork(trainData,trainLabels,layers,options);

% Testing of the rpoposed netwrok
YPred = classify(net, testData);
c = sum(YPred == testLabels) / numel(testLabels);
disp(['Test accuracy: ', num2str(c)]);



%+++++++++++++++++++++++++++++++++++++++++++++++ END OF SCRIPT +++++++++++++++++++++++++++++++