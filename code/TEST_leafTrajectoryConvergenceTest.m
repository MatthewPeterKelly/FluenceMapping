% MAIN_leafTrajectoryConvergenceTest
%
% This script performs 3 grid sweeps:
% 1) leaf blocking smoothing
% 2) velocity smoothing
% 3) number of grid points in spline
%
%

clc; clear;

tBnd = [0, 5];
xBnd = [0, 2];
vBnd = [0, 0.5];

smoothList.leafBlocking = (200/diff(xBnd))*logspace(-2

% parameters for the leaf trajectory fitting
param.limits.velocity = vBnd;
param.smooth.leafBlocking = 500/diff(xBnd);
param.smooth.velocityObjective = 1e-2;
param.nSubSample = 10;
param.guess.defaultLeafSpaceFraction = 0.25;

% parameters for fmincon:
param.fmincon = optimset(...
    'Display', 'iter');

% Random dose trajectory
nGrid = 8;
dose.tGrid = linspace(tBnd(1), tBnd(2), nGrid);
dose.rGrid = 3*rand(1, nGrid);

% Use the default initialization for now
guess = [];

% Create a smooth test fluence map:
nModel = 5;
xFluence = linspace(xBnd(1), xBnd(2), nModel);
fFluence = 4*rand(1,nModel); fFluence([1,end]) = 0;
nFluenceGrid = 25;
target.xGrid = linspace(xBnd(1), xBnd(2), nFluenceGrid);
target.fGrid = pchip(xFluence',fFluence',target.xGrid')';

% sample the fluence profile densely for plotting:
xFluencePlot = linspace(xBnd(1), xBnd(2), 100);
fFluencePlot = pchip(xFluence',fFluence',xFluencePlot')';

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

subplot(2,2,4); hold on;
plot(tGrid, soln.traj.dose, 'g-o');
xlabel('time')
ylabel('fluence dose')

subplot(2,2,1); hold on;
plot(soln.target.fGrid, soln.target.xGrid,'rx')
plot(fFluencePlot, xFluencePlot,'r-','LineWidth',1)
plot(soln.target.fSoln, soln.target.xGrid,'k--o','LineWidth',2)
xlabel('time')
ylabel('fluence dose')
legend('Fitting Points','Fluence Target', 'Fluence Soln');
