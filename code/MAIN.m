% MAIN --

clc; clear;

% Load the example:
% filename = 'sampleData/twohumps.mat';
filename = 'sampleData/twodips.mat';
[fluenceFun, xBnd] = loadProfile(filename);


nGridT = 4;  % grid on which to evaluate the dose rate
nGridX = 15;  % grid on which to evaluate the fluence
maxRate = 3;
tBnd = [0, 2*(xBnd(2)-xBnd(1))/maxRate];
tGrid = linspace(tBnd(1),tBnd(2), nGridT)';
xGrid = linspace(xBnd(1), xBnd(2), nGridX)';
maxDose = 10;
tDose = linspace(tGrid(1), tGrid(end), 5)';

options = cmaes('defaults');
options.MaxIter = 5;
options.TolX = 0.1;
options.LBounds = zeros(size(tDose));
options.UBounds = maxDose*ones(size(tDose));
options.DispModulo = 1;
options.LogModulo = 0;
options.PopSize = 8;

% Compute the sample fluence profile:
xFluence = linspace(xBnd(1), xBnd(2), 5);

% Compute the optimal dose trajectories:
[doseFun, xLowGrid, xUppGrid] = optimizeDoseTrajectories(tGrid, xGrid, tDose, fluenceFun, maxDose, options);

% Compute the fluence for the solution:
fGrid = getFluenceProfile(xGrid, tGrid, xLowGrid, xUppGrid, doseFun);

figure(5); clf;
plotFluenceFitting(tGrid,xLowGrid,xUppGrid,tDose,doseFun,xGrid,fGrid, fluenceFun);



