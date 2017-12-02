% This script loads a sample fluence-fitting profile from a data set and
% then fits the leaf trajectories to that data set.
%

clc; clear;

fileName = 'sampleData/realFluenceMapData.mat'; % loads: targetFluence
figNum = 1028;
load(fileName);

iRow = 30; % max row is 42

tBnd = [0, 8];  % Time
xBnd = targetFluence.rowSlicePosBnd ;  % Bound on leaf position
vBnd = targetFluence.maxLeafSpeed*[-1,1];  % bounds on leaf velocity
rBnd = [0, 1]*targetFluence.maxDoseRate; % bounds on dose rate

nGrid = 5;  % Number of grid points for trajectories

% parameters for the leaf trajectory fitting
param.limits.position = xBnd;
param.limits.velocity = vBnd;
param.smooth.leafBlockingWidth = 0.05*diff(xBnd);  % 0.01 = more precise, 0.1 = faster
param.smooth.leafBlockingFrac = 0.96;  % Change in smoothing over width (0.99 = more precise, 0.9 = faster)
param.smooth.velocityObjective = 1e-6;   % 1e-6 = more precise, 1e-3 faster, smooth leaf traj
param.nQuad = 20;  % number of segments to use for quadrature. 50 = more precise, 10 = faster.
param.guess.defaultLeafSpaceFraction = 0.2;

% Parameters for dose trajectory fitting
param.smooth.doseObjective = 1e-1;   % 1e-1 = more precise, 1e-2 smoother dose profile, faster

% parameters for fmincon:
param.fmincon = optimset(...
    'Display', 'off', ...
    'MaxIter', 100, ...
    'TolFun', 1e-3,...
    'TolX', 1e-3);

% Initial guess at the dose rate trajectory
dose.tGrid = linspace(tBnd(1), tBnd(2), nGrid);
dose.rGrid = mean(rBnd)*ones(1,nGrid);

% Fluence target from data set:
target.xGrid = targetFluence.rowSlice(iRow).xGrid;
target.dx = mean(diff(targetFluence.rowSlice(iRow).xGrid));
target.fGrid = targetFluence.rowSlice(iRow).fGrid;

% Use the default initialization for now
guess = [];

% sample the fluence profile densely for plotting:
xFluencePlot = target.xGrid ;
fFluencePlot = targetFluence.rowSlice(iRow).fGrid;

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
set(gca,'YLim',xBnd);

h = subplot(2,2,4); hold on;
plot(tGrid, soln.traj.dose, 'g-o');
xlabel('time')
ylabel('fluence dose')
h.YLim = [0, h.YLim(2)];

subplot(2,2,1); hold on;
plot(soln.target.fGrid, soln.target.xGrid,'rx')
plot(fFluencePlot, xFluencePlot,'r-','LineWidth',1)
plot(soln.target.fSoln, soln.target.xGrid,'ko','LineWidth',2)
ylabel('position')
xlabel('fluence dose')
legend('Fitting Points','Fluence Target', 'Fluence Soln');
set(gca,'YLim',xBnd);
