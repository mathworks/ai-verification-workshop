%[text] # Getting Started: Find Adversarial Examples
%[text] In this exercise, you will load a pretrained digit classifier, generate adversarial examples that fool the network, and visualize the results. This demonstrates why AI verification matters: even well-trained networks can be fooled by imperceptible perturbations.
%[text] **Duration:** ~5 minutes
%[text] **What you will learn:**
%[text] - How small, imperceptible perturbations can cause neural networks to misclassify inputs
%[text] - How to use `findAdversarialExamples` from the AI Verification Library \
%%
%[text] ## Load the Pretrained Network
%[text] *What we are doing:* Loading a small convolutional neural network trained to classify handwritten digits (0-9). This network was prepared by `startup.m` and saved to the `models/` folder.
%[text] *Why this matters:* We need a working network to demonstrate that even a well-trained classifier can be fooled by tiny input changes.
%[text] *What to expect:* The variable `net` should appear in your workspace as a `dlnetwork` object.
rng("default")
load(fullfile("models","digitsClassificationConvolutionNet.mat"),"net")
classNames = categorical(0:9);
%%
%[text] ## Load and Classify Test Images
%[text] *What we are doing:* Loading 10 random test images from the MNIST digit dataset and classifying them with the pretrained network. The images are 28x28 grayscale with pixel values in \[0, 1\].
%[text] *Why this matters:* We first confirm the network classifies these images correctly before searching for adversarial perturbations.
%[text] *What to expect:* `YTest` should display 10 predicted labels that match (or mostly match) the true labels.
[XTest,TTest] = digitTest4DArrayData;
numInputs = 10;
testIdx = randi(numel(TTest),numInputs);
imgs = XTest(:,:,:,testIdx);
labels = TTest(testIdx,:)'
X = dlarray(single(imgs),"SSCB");
scores = predict(net,X);
YTest = scores2label(scores,classNames)
%%
%[text] ## Define Perturbation Bounds
%[text] *What we are doing:* Creating upper and lower bounds around each input image. The perturbation size of 0.1 means each pixel can change by at most 10% of the full \[0, 1\] range. We clip bounds to stay within valid pixel values.
%[text] *Why this matters:* The adversarial search looks for misclassifications *within* this region. A perturbation of 0.1 is small enough that the altered image looks identical to the human eye.
perturbationSize = 0.1;
XLower = max(X - perturbationSize, 0);
XUpper = min(X + perturbationSize, 1);

% Visualize lower bound, original, and upper bound for the first input
figure;
tiledlayout(1,3, "Padding", "compact", "TileSpacing", "compact");

% XLower
nexttile;
imshow(squeeze(gather(extractdata(XLower(:,:,:,1)))));
title("XLower");

% X (original)
nexttile;
imshow(squeeze(gather(extractdata(X(:,:,:,1)))));
title("X (original)");

% XUpper
nexttile;
imshow(squeeze(gather(extractdata(XUpper(:,:,:,1)))));
title("XUpper");
%%
%[text] ## Find Adversarial Examples
%[text] *What we are doing:* Calling `findAdversarialExamples` to search for inputs within the perturbation bounds that cause the network to change its prediction.
%[text] The function returns:
%[text] - `examples` -- the adversarial images found
%[text] - `mislabels` -- the incorrect labels assigned by the network
%[text] - `iX` -- indices into the original batch for which adversarial examples were found \
%[text] *What to expect:* The function should find at least one adversarial example.
% ADD 1 LINE OF CODE HERE
%%
%[text] ## Visualize Original vs. Adversarial
%[text] *What we are doing:* Displaying the first adversarial example side-by-side with its original image.
%[text] *What to expect:* The two images should look nearly identical to your eye, but the network classifies them as different digits.
numAdversarialExamples = numel(mislabels);
adversarialExampleIndex = 1; %[control:slider:7d3d]{"position":[27,28]}
inputIndex = iX(adversarialExampleIndex);

figure
tiledlayout(1,2);
nexttile(1);
imshow(imgs(:,:,:,inputIndex));
title({"Original (True: " + string(labels(inputIndex)) + ")", "Predicted: " + string(YTest(inputIndex))});
nexttile(2)
imshow(extractdata(examples(:,:,:,adversarialExampleIndex)));
title({"Adversarial (True: " + string(labels(inputIndex)) + ")", "Predicted: " + string(mislabels(inputIndex))})
%%
%[text] ## What Just Happened?
%[text] You found an image that looks almost identical to the original but causes the network to predict a completely different digit. This is an *adversarial example* -- a small, crafted perturbation that exploits the network's decision boundaries.
%[text] The inability to find an adversarial example does not prove none exist. In the next exercise, you will use *formal verification* methods to mathematically prove that a safety-critical network is robust -- or identify where it is not.
%%
%[text] ## Export Results
%[text] Uncomment the lines below to export this script as an HTML report.
% if ~isfolder("results"), mkdir("results"); end
% export("Part1_GettingStarted.m", fullfile("results", "Part1_GettingStarted.html"));
%%
%[text] *Copyright 2026 The MathWorks, Inc.*

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
%[control:slider:7d3d]
%   data: {"defaultValue":1,"label":"adversarialExampleIndex","max":93,"maxLinkedVariable":"numAdversarialExamples","min":1,"run":"Section","runOn":"ValueChanging","step":1}
%---
