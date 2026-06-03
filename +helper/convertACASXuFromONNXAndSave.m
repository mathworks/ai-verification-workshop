function convertACASXuFromONNXAndSave(matFolder)
%convertACASXuFromONNXAndSave Convert ACAS Xu ONNX networks to MAT format
%   convertACASXuFromONNXAndSave(matFolder) finds all ONNX files in the
%   parent directory of matFolder, imports each as a dlnetwork, and saves
%   to matFolder as MAT files.
%
% Copyright 2026 The MathWorks, Inc.

if ~isfolder(matFolder)
    mkdir(matFolder);
end

onnxFolder = fileparts(matFolder);
onnxFiles = dir(fullfile(onnxFolder, "*.onnx"));

for ii = 1:numel(onnxFiles)
    [~, name] = fileparts(onnxFiles(ii).name);
    matPath = fullfile(matFolder, name + ".mat");
    if ~isfile(matPath)
        onnxPath = fullfile(onnxFolder, onnxFiles(ii).name);
        net = importNetworkFromONNX(onnxPath);
        save(matPath, "net");
    end
end
end
