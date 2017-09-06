% This script loads a sample fluence-fitting profile from a data set and
% then fits the leaf trajectories to that data set.
%

clc; clear;

fileName = 'sampleData/realFluenceMapData.mat'; % loads: targetFluence
figNum = 1028;
load(fileName);

iRowSet = 26:29; % max row is 42

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
param.smooth.doseObjective = 1e-1;   

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
nTarget = length(iRowSet);
for iTarget = 1:nTarget
    iRow = iRowSet(iTarget);
    target(iTarget).xGrid = targetFluence.rowSlice(iRow).xGrid; %#ok<*SAGROW>
    target(iTarget).dx = mean(diff(targetFluence.rowSlice(iRow).xGrid));
    target(iTarget).fGrid = targetFluence.rowSlice(iRow).fGrid;
end

% Set up the initial guess, limits, and search domain for cmaes
zGuess = dose.rGrid';
zLow = rBnd(1)*ones(nGrid,1);
zUpp = rBnd(2)*ones(nGrid,1);
zSigma = 0.5*(zUpp - zLow);

% Set up the options for CMAES
options = cmaes('defaults');
options.LBounds = zLow;
options.UBounds = zUpp;
options.MaxFunEvals = 500;
options.MaxIter = 50;
options.TolX = 0.01*diff(rBnd);
options.TolFun = 1e-4;
options.EvalInitialX = 'yes';
options.DispModulo = 1;
options.SaveVariables = 'off';
options.SaveFilename = '';


% Use the default initialization for now
guess = [];

%% Call CMAES
[xMin, fMin, countEval, stopFlag, output, bestEver] = cmaes(...
    'leafTrajMultiFitObj', zGuess, zSigma, options, ...  % standard arguments
    dose, guess, target, param);  % pass through to objective

%% Get the best-ever solution:
[objVal, soln] = leafTrajMultiFitObj(bestEver.x, dose, guess, target, param);

% Plots!
for iSoln = 1:length(soln)

figure(5235 + iSoln); clf;
tGrid = soln(iSoln).traj.time;

subplot(2,2,2); hold on;
plot(tGrid, soln(iSoln).traj.xLow,'r-o');
plot(tGrid, soln(iSoln).traj.xUpp,'b-o');
xlabel('time');
ylabel('leaf position');
legend('Leaf One','Leaf Two');
set(gca,'YLim',xBnd);

h = subplot(2,2,4); hold on;
plot(tGrid, soln(iSoln).traj.dose, 'g-o');
xlabel('time')
ylabel('fluence dose')
h.YLim = [0, h.YLim(2)];

subplot(2,2,1); hold on;
plot(soln(iSoln).target.fGrid, soln(iSoln).target.xGrid,'rx-')
plot(soln(iSoln).target.fSoln, soln(iSoln).target.xGrid,'ko-','LineWidth',2)
ylabel('position')
xlabel('fluence dose')
legend('Fluence Target', 'Fluence Soln');
set(gca,'YLim',xBnd);
title(['Fluence Fitting, Row Index: ' num2str(iSoln)]);

save2pdf(['MultiVMat_Row-' num2str(iSoln) '.pdf']);

end