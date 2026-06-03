function setupModels(rootDir)
%setupModels Prepare data and models required by the workshop
%   setupModels(rootDir) trains the digit classification network (if not
%   already present) and downloads the ACAS Xu dataset (if not already
%   present).
%
% Copyright 2026 The MathWorks, Inc.

% Prepare digit classification network for Stage 1
digitNetPath = fullfile(rootDir, "models", "digitsClassificationConvolutionNet.mat");
if ~isfile(digitNetPath)
    disp("Training digit classification network for Stage 1...");
    trainDigitClassificationNet(digitNetPath);
else
    disp("Digit classification network already present.");
end

% Download ACAS Xu dataset if needed (for Stages 2 and 3)
dataFolder = fullfile(rootDir, "models", "acas-xu-neural-network-dataset");
if ~isfolder(dataFolder)
    disp("Downloading ACAS Xu dataset (required for Stages 2 and 3)...");
    downloadACASXuData(rootDir);
else
    disp("ACAS Xu dataset already present.");
end
end
