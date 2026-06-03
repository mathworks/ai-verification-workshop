function adaptiveMeshProgressMonitor
%adaptiveMeshProgressMonitor Open a figure for real-time adaptive mesh visualization
%   adaptiveMeshProgressMonitor creates a figure with theta-psi axes and a
%   legend for the 5 ACAS Xu advisory classes. Verified regions are drawn
%   as colored rectangles during the adaptive mesh loop.
%
% Copyright 2026 The MathWorks, Inc.

figure
axis equal
xlim([-pi pi])
ylim([-pi pi])
xticks(-pi:pi/4:pi)
yticks(-pi:pi/4:pi)
tickLabels = {'$-\pi$','$-\frac{3\pi}{4}$','$-\frac{\pi}{2}$','$-\frac{\pi}{4}$', ...
    '$0$','$\frac{\pi}{4}$','$\frac{\pi}{2}$','$\frac{3\pi}{4}$','$\pi$'};
xticklabels(tickLabels)
yticklabels(tickLabels)
set(gca,TickLabelInterpreter="latex");
xlabel("$\theta$",Interpreter="latex")
ylabel("$\psi$",Interpreter="latex")
title("Stable Regions of ODD")
grid on
for ii = 1:5
    hold on
    plot(-100,-100,"square", ...
        Color=helper.getClassColors(ii), ...
        MarkerFaceColor=helper.getClassColors(ii), ...
        MarkerEdgeColor=helper.getClassColors(ii));
end
hold off
legend(helper.classNames,Location="eastoutside");
end
