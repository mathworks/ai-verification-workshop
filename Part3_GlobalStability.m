%[text] # Verify Global Stability of ACAS Xu Using Adaptive Mesh
%[text] In this exercise, you will verify the global stability of an ACAS Xu collision avoidance network across its entire operational design domain (ODD). Instead of verifying robustness at a single point, you will partition the full input space into hypercuboids, verify each one, and adaptively refine regions that cannot be proven stable -- building a complete verification map.
%[text] **Duration:** ~25 minutes
%[text] **What you will learn:**
%[text] - How adaptive mesh verification scales formal methods to an entire input domain
%[text] - How the algorithm concentrates computational effort on decision boundaries
%[text] - How to quantify what proportion of the ODD has been formally verified \
%%
%[text] ## Background: From Local to Global Verification
%[text] In the previous exercise, you verified robustness at a single operating point. But safety-critical systems must be verified across their *entire* operational envelope. A uniform grid approach wastes computation: most of the input space is far from decision boundaries and verifies easily, while boundary regions need fine resolution.
%[text] The **adaptive mesh** algorithm starts with the entire ODD as one hypercuboid. If verification succeeds, the region is marked stable. If unproven, the hypercuboid is bisected along its widest angular dimension and each half is re-verified.
%%
%[text] ## Load the Network
%[text] *What we are doing:* Loading the same ACAS Xu network from the previous exercise (previous advisory = Clear-of-Conflict, $\\tau = 1$).
timeUntilLossOfVerticalSeparation = 1;
previousAdvisory = 1;
net = helper.loadACASNetwork(previousAdvisory, timeUntilLossOfVerticalSeparation);
%%
%[text] ## Configure the Operational Design Domain
%[text] *What we are doing:* Defining the ODD for our analysis. We fix the distance ($\rho = 15{,}000$ ft) and velocities ($v\_{own} = 954.6$ ft/s, $v\_{int} = 1050$ ft/s) while sweeping the two heading angles ($\\theta$ and $\\psi$) across the full range $\[-\\pi, \\pi\]$. This gives a 2D verification domain.
%[text] The `minAngle` parameter sets the minimum hypercuboid width (in radians) to prevent infinite subdivision. We use 0.05 for this workshop to keep runtime short.
minAngle = 0.05;
miniBatchSize = 4096;

rho = 15000;
vOwn = 954.6;
vInt = 1050;

thetaLower = -pi;
thetaUpper = pi;
psiLower = -pi;
psiUpper = pi;

oddLower = [rho thetaLower psiLower vOwn vInt];
oddUpper = [rho thetaUpper psiUpper vOwn vInt];
%%
%[text] ## Initialize Data Structures
%[text] *What we are doing:* Creating the initial hypercuboid spanning the entire ODD, a queue for processing, and storage for verified results.
%[text] *What to expect:* The progress monitor figure should open, showing an empty $\\theta$-$\\psi$ plot that will fill in as regions are verified.
oddLower = dlarray(oddLower, "BC");
oddUpper = dlarray(oddUpper, "BC");

cubes = helper.CubeBatch(oddLower, oddUpper);
verifiedCubes = helper.CubeBatch;
cubeQueue = helper.CubeBatchQueue;
enqueue(cubeQueue, cubes);

numHypercuboids = 0;
verifiedLabelBatch = [];
hypercuboidCenters = [];
helper.adaptiveMeshProgressMonitor;
%%
%[text] ## Run the Adaptive Mesh Verification Loop
%[text] *What we are doing:* The main loop repeatedly: (1) retrieves a batch of hypercuboids from the queue, (2) predicts the advisory at each center, (3) calls `verifyNetworkRobustness` to check if the predicted advisory holds across the entire region, (4) stores verified regions and bisects unproven ones.
%[text] *Why this matters:* This is the core of scalable formal verification. Verified regions are proven stable -- every input in that region provably produces the same advisory.
%[text] *What to expect:* Watch the figure update in real time. Colored rectangles represent verified regions. The algorithm concentrates subdivisions near decision boundaries. 
while ~isempty(cubeQueue)
    cubes = getCubes(cubeQueue, miniBatchSize);

    centers = getCenters(cubes);
    hypercuboidCenters = [hypercuboidCenters extractdata(centers)]; %#ok<AGROW>

    advisory = predict(net, centers);
    [~, idxLabel] = max(extractdata(advisory));

    results = verifyNetworkRobustness(net, cubes.xLower, cubes.xUpper, idxLabel, MiniBatchSize=miniBatchSize);
    idxVerified = (results == "verified");
    idxUnproven = (results == "unproven");

    verifiedMiniBatch = getSubset(cubes, idxVerified);
    verifiedLabel = idxLabel(idxVerified);
    verifiedLabelBatch = [verifiedLabelBatch verifiedLabel]; %#ok<AGROW>
    verifiedCubes = addSubset(verifiedCubes, verifiedMiniBatch);

    xlVerified = extractdata(verifiedMiniBatch.xLower);
    xuVerified = extractdata(verifiedMiniBatch.xUpper);
    sideLengths = xuVerified - xlVerified;
    for kk = 1:getNumCubes(verifiedMiniBatch)
        hold on
        rectangle( ...
            Position=[xlVerified(2,kk) xlVerified(3,kk) sideLengths(2,kk) sideLengths(3,kk)], ...
            FaceColor=[helper.getClassColors(verifiedLabel(kk)) 0.05], ...
            EdgeColor="none");
    end
    hold off
    drawnow

    unprovenCubes = getSubset(cubes, idxUnproven);
    helper.bisectAndUpdateQueue(cubeQueue, unprovenCubes, minAngle);

    numHypercuboids = numHypercuboids + getNumCubes(cubes);
end
%%
%[text] ## Compare Network Prediction to Stability Analysis
%[text] *What we are doing:* Verifying that network predictions at specific sample points match the verified regions in the plot.
%[text] *What to expect:* Each sample point should produce an advisory that matches the color of the region it falls in on the plot.
samplePoints = [
    rho -3.00  3.00 vOwn vInt;
    rho -1.50  1.00 vOwn vInt;
    rho -0.78  2.10 vOwn vInt;
    rho -0.78  1.57 vOwn vInt;
    rho -0.39  1.97 vOwn vInt;
    rho  0.70 -1.57 vOwn vInt;
    rho  0.78 -0.78 vOwn vInt;
    rho  0.90 -1.57 vOwn vInt;
    rho  1.57 -0.78 vOwn vInt;
    rho  0.95 -1.97 vOwn vInt];

sampleAdvisory = predict(net, samplePoints);
sampleAdvisory = scores2label(sampleAdvisory, helper.classNames)
%%
%[text] ## Compute Proportion of ODD Verified Stable
%[text] *What we are doing:* Calculating what fraction of the ODD was formally verified as stable.
%[text] *What to expect:* With `minAngle=0.1`, you should see a high proportion verified (typically \>90%). The unverified regions contain the decision boundaries.
totalVolume = prod(oddUpper(2:3) - oddLower(2:3));
verifiedCubeVolume = sum(prod(verifiedCubes.xUpper(2:3,:) - verifiedCubes.xLower(2:3,:)));
disp("Stable proportion of ODD: " + extractdata(verifiedCubeVolume / totalVolume))
disp("Number of hypercuboids: " + numHypercuboids)
%%
%[text] ## Visualize Class Proportions
%[text] *What we are doing:* Plotting a bar chart showing how much of the ODD belongs to each advisory class, plus the unverified fraction.
helper.plotClassProportion(verifiedLabelBatch, verifiedCubes, totalVolume)
%%
%[text] ## Visualize Hypercuboid Density
%[text] *What we are doing:* Plotting a 2D histogram of hypercuboid center locations. High bars indicate the presence of decision boundaries where the algorithm performed the most subdivisions.
helper.plotHypercuboidDensity(hypercuboidCenters)
%%
%[text] ## Summary
%[text] You verified the global stability of an ACAS Xu network across its full $\\theta$-$\\psi$ operating domain using adaptive mesh refinement. Key takeaways:
%[text] 1. The adaptive mesh concentrates computation on decision boundaries, avoiding waste in stable interior regions
%[text] 2. A high proportion of the ODD can be formally verified as stable
%[text] 3. Unverified regions are narrow bands at class transitions, which may require finer resolution or stronger algorithms \
%[text] **Try this:** Re-run the loop with `minAngle = 0.05` for higher resolution. How does the verified proportion change? How many more hypercuboids are processed?
%%
%[text] ## Export Results
%if ~isfolder("results"), mkdir("results"); end
%export("Part3_GlobalStability.m", fullfile("results", "Part3_GlobalStability.html"));
%%
%[text] *Copyright 2026 The MathWorks, Inc.*

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
