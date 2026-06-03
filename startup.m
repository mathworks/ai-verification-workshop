% startup.m — AI Verification Workshop environment setup
% Run this script first to configure paths and verify that
% Deep Learning Toolbox(TM) and AI Verification Library for
% Deep Learning Toolbox(TM) are installed.
%
% Copyright 2026 The MathWorks, Inc.

%% Add project folders to path
rootDir = fileparts(mfilename('fullpath'));
addpath(genpath(rootDir));

%% Verify required toolboxes
requiredToolboxes = "Deep Learning Toolbox";
installedToolboxes = string({ver().Name});
missingToolboxes = setdiff(requiredToolboxes, installedToolboxes);
if ~isempty(missingToolboxes)
    warning("Missing toolboxes: %s", join(missingToolboxes, ", "));
else
    disp("All required toolboxes are installed.");
end

%% Verify required add-ons
requiredAddons = "AI Verification Library for Deep Learning Toolbox";
addons = matlab.addons.installedAddons;
missingAddons = setdiff(requiredAddons, addons.Name);
if ~isempty(missingAddons)
    warning("Missing add-ons: %s" + newline + "  Install via Add-On Explorer.", join(missingAddons, ", "));
else
    disp("All required add-ons are installed.");
end

%% Prepare models
helper.setupModels(rootDir);

disp("Workshop setup complete. Open Part1_GettingStarted.m to begin.");
