% This script loads a sample fluence-fitting profile from a data set and
% then fits the leaf trajectories to that data set.
%

clc; clear;

% Parameters for the script
iRow = 28; % max row is 42  -- which row from the data set to run
duration = 3; % how long should fluence delivery take?
nGrid = 5;  % Number of grid points for trajectories


% Load the data for fitting:
fluenceTargetData = getDataSet();
tBnd = [0, duration];  
xBnd = fluenceTargetData.rowBnd ;  % Bound on leaf position
vBnd = fluenceTargetData.maxLeafSpeed*[-1,1];  % bounds on leaf velocity

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

% Use a constant (at max) dose rate trajectory. 
dose.tGrid = linspace(tBnd(1), tBnd(2), nGrid);
dose.rGrid = fluenceTargetData.maxDoseRate*ones(1,nGrid);

% Fluence target from data set:
nTarget = size(fluenceTargetData.raw, 2);
target.xGrid = linspace(xBnd(1), xBnd(end), nTarget);
target.dx = target.xGrid(2) - target.xGrid(1);
target.fGrid = fluenceTargetData.raw(iRow, :);

% Use the default initialization for now
guess = [];

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
plot(soln.target.fGrid, soln.target.xGrid,'r--x','LineWidth',2,'MarkerSize',8)
plot(soln.target.fSoln, soln.target.xGrid,'k-o','LineWidth',2)
ylabel('position')
xlabel('fluence dose')
legend('Fluence Target', 'Fluence Delivered');
set(gca,'YLim',xBnd);
