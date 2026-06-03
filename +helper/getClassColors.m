function classColours = getClassColors(idx)
%getClassColors Return RGB color for ACAS Xu advisory class index
%   classColours = getClassColors(idx) returns the RGB triplet for the
%   given class index (1-5).
%
% Copyright 2026 The MathWorks, Inc.

classColours = [
    0.0902    0.5490    0.3922;
    0.6706    0.7843    0.8196;
    1.0000    0.8000         0;
         0         0    0.5451;
    1.0000    0.5490         0];
classColours = classColours(idx,:);
end
