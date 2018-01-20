% This script creates a sample fluence-fitting problem, generates a random
% dose-rate trajectory, and then computes the leaf-trajectories that
% do the best job of fitting those trajectories.
% This script creates a smooth target fluence profile and then uses the
% leaf-fitting optimization to compute the optimal leaf trajectory. The
% dose rate trajectory is set arbitrarily.
%

clc; clear;

tBnd = [0, 5];
xBnd = [0, 2];
vBnd = 0.5*[-1, 1];

% parameters for the leaf trajectory fitting
param.limits.time = tBnd;
param.limits.position = xBnd;
param.limits.velocity = vBnd;
param.smooth.leafBlockingWidth = 0.02*diff(xBnd);
param.smooth.leafBlockingFrac = 0.95;  % Change in smoothing over width
param.smooth.velocityObjective = 1e-4;
param.nQuad = 20;  % Number of segments for quadrature calculations
param.guess.defaultLeafSpaceFraction = 0.2;

nKnot = 8;
nFit = 5*nKnot;

% parameters for fmincon:
param.fmincon = optimset(...
    'Display', 'iter',...
    'TolFun', 1e-3);

% Diagnostics parameters
param.diagnostics.nQuad = 10*param.nQuad;
param.diagnostics.alpha = getExpSmoothingParam(0.999, 0.001);

% Arbitrary dose trajectory for testing:
doseProfile.tGrid = linspace(tBnd(1), tBnd(2), 5);
doseProfile.fGrid = 1.0*[1, 1.8, 2.5, 1.8, 1.9];

% doseProfile.fGrid = 0.5*ones(size(doseProfile.tGrid));

doseProfile.pp = pchip(doseProfile.tGrid, doseProfile.fGrid);
dose.tGrid = linspace(tBnd(1), tBnd(2), nKnot);
dose.rGrid = ppval(doseProfile.pp, dose.tGrid);

% Arbitrary fluence target for testing:
fluenceProfile.tGrid = linspace(xBnd(1), xBnd(2), 6);
fluenceProfile.fGrid = [0.1, 0.8, 1.8, 0.2, 0.6, 0.0];
fluenceProfile.pp = pchip(fluenceProfile.tGrid, fluenceProfile.fGrid);
xGrid = linspace(xBnd(1), xBnd(2), nFit+1);
xMid = 0.5*(xGrid(1:nFit) + xGrid(2:end));
dx = xGrid(2:end) - xGrid(1:nFit);
target.xGrid = xMid;
target.dx = dx;
target.fGrid = ppval(fluenceProfile.pp, target.xGrid);

% Random dose trajectory
% Use the default initialization for now
guess = [];

% sample the fluence profile densely for plotting:
xFluencePlot = linspace(xBnd(1), xBnd(2), 100);
fFluencePlot = ppval(fluenceProfile.pp, xFluencePlot);

% Solve!
soln = fitLeafTrajectories(dose, guess, target, param);

% Plots!
figure(5235); clf;
tGrid = soln.traj.time;

subplot(2,2,2); hold on;
plot(tGrid, soln.traj.xLow,'r-o');
plot(tGrid, soln.traj.xUpp,'b-o');
xlabel('time');
ylabel('leaf position');
legend('Leaf One','Leaf Two');

h = subplot(2,2,4); hold on;
plot(tGrid, soln.traj.dose, 'g-o');
xlabel('time')
ylabel('fluence dose')
h.YLim = [0, h.YLim(2)];

subplot(2,2,1); hold on;
plot(soln.target.fGrid, soln.target.xGrid,'rx')
plot(fFluencePlot, xFluencePlot,'r-','LineWidth',1)
plot(soln.target.fSoln, soln.target.xGrid,'ko','LineWidth',2)
xlabel('time')
ylabel('fluence dose')
legend('Fitting Points','Fluence Target', 'Fluence Soln');
