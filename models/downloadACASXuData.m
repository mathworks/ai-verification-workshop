function downloadACASXuData(rootDir)
%downloadACASXuData Download and prepare the ACAS Xu neural network dataset
%   downloadACASXuData(rootDir) downloads the ACAS Xu dataset ZIP from
%   MathWorks support files, extracts it into the models/ folder, and
%   converts the ONNX networks to MAT format.
%
% Copyright 2026 The MathWorks, Inc.

if nargin == 0
    rootDir = fileparts(fileparts(mfilename('fullpath')));
end

dataDir = fullfile(rootDir, "models");

% Download the dataset
disp("Downloading ACAS Xu neural network dataset...");
zipFile = matlab.internal.examples.downloadSupportFile( ...
    "nnet", "data/acas-xu-neural-network-dataset.zip");

% Extract to models folder — the zip creates a nested
% acas-xu-neural-network-dataset/ subfolder inside dataDir
disp("Extracting dataset...");
unzip(zipFile, dataDir);

% Convert ONNX networks to MAT format
matFolder = fullfile(dataDir, "acas-xu-neural-network-dataset", "networks-mat");
disp("Converting ONNX networks to MAT format...");
helper.convertACASXuFromONNXAndSave(matFolder);

disp("ACAS Xu data download and conversion complete.");
end
