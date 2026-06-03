function plotClassProportion(labelVerified, verifiedCubes, totalVolume)
%plotClassProportion Bar chart of verified ODD proportion by advisory class
%   plotClassProportion(labelVerified, verifiedCubes, totalVolume) computes
%   and plots the fraction of the operational design domain that has been
%   verified for each of the 5 ACAS Xu advisory classes, plus the
%   unverified remainder.
%
% Copyright 2026 The MathWorks, Inc.

propVerifiedVolumePerClass = zeros(1,5);
for idxLabel = 1:5
    predictClassIdx = (labelVerified == idxLabel);
    verifiedCubeVolumePerClass = sum(prod( ...
        verifiedCubes.xUpper(2:3, predictClassIdx) - ...
        verifiedCubes.xLower(2:3, predictClassIdx)));
    propVerifiedVolumePerClass(idxLabel) = verifiedCubeVolumePerClass / totalVolume;
end
propVerifiedVolumePerClass(end+1) = 1 - sum(propVerifiedVolumePerClass);
figure
b = bar([helper.classNames "Unverified"], ...
    extractdata(propVerifiedVolumePerClass));
b.FaceColor = "flat";
for idx = 1:5
    b.CData(idx,:) = helper.getClassColors(idx);
end
b.CData(6,:) = [0.5 0.5 0.5];
ylim([0 1])
text(1:length(propVerifiedVolumePerClass), ...
    extractdata(propVerifiedVolumePerClass), ...
    num2str(extractdata(propVerifiedVolumePerClass)',"%.2f"), ...
    vert="bottom",horiz="center");
title("Proportion of ODD by Class")
end
