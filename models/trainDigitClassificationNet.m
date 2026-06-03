function trainDigitClassificationNet(savePath)
%trainDigitClassificationNet Train a small CNN on MNIST digits and save
%   trainDigitClassificationNet(savePath) trains a convolutional network
%   on the built-in digit dataset and saves the dlnetwork to savePath.
%
% Copyright 2026 The MathWorks, Inc.

[XTrain, TTrain] = digitTrain4DArrayData;

layers = [
    imageInputLayer([28 28 1], Normalization="none")
    convolution2dLayer(5, 20, Padding="same")
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, Stride=2)
    convolution2dLayer(3, 50, Padding="same")
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, Stride=2)
    fullyConnectedLayer(10)
    softmaxLayer
    classificationLayer]; %#ok<CLASLAYER>

options = trainingOptions("adam", ...
    MaxEpochs=10, ...
    MiniBatchSize=128, ...
    Shuffle="every-epoch", ...
    Verbose=false, ...
    Plots="none");

trainedNet = trainNetwork(XTrain, TTrain, layers, options); %#ok<TRNETW>
net = dag2dlnetwork(trainedNet);

save(savePath, "net");
disp("Digit classification network trained and saved.");
end
