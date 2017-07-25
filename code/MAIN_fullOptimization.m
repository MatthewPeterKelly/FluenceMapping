% This script creates a sample fluence-fitting problem, and then computes
% the dose rate and leaf trajectories that best-fit the fluence profile.
%
% Outer optimization: dose rate -- CMAES
% Innter optimization: leaf positions -- FMINCON

%%

clc; clear;

tBnd = [0, 4];  % Time
xBnd = [0, 2];   % bounds on leaf position
vBnd = [0, 1];  % bounds on leaf velocity
rBnd = [0, 4]; % bounds on dose rate

% parameters for the leaf trajectory fitting
param.limits.velocity = vBnd;
param.smooth.leafBlockingWidth = 0.05*diff(xBnd);
param.smooth.leafBlockingFrac = 0.95;  % Change in smoothing over width
param.smooth.velocityObjective = 1e-5;
param.nQuad = 20;
param.guess.defaultLeafSpaceFraction = 0.2;

% Parameters for dose trajectory fitting
param.smooth.doseObjective = 1e-2;

% parameters for fmincon:
param.fmincon = optimset(...
    'Display', 'off', ...
    'MaxIter', 100, ...
    'TolFun', 1e-3,...
    'TolX', 1e-3);

% Initial guess at the dose rate trajectory
nGrid = 5;
dose.tGrid = linspace(tBnd(1), tBnd(2), nGrid);
dose.rGrid = mean(rBnd)*ones(1,nGrid);

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

% Use the default initialization for leaf trajectories for now
guess = [];

% Create a smooth test fluence map:
nFluenceModel = 5;
xFluence = linspace(xBnd(1), xBnd(2), nFluenceModel);
fFluence = rand(1,nFluenceModel); fFluence([1,end]) = 0;
nFit = 5*nGrid;
xGrid = linspace(xBnd(1), xBnd(2), nFit+1);
target.xGrid = 0.5*(xGrid(2:end) + xGrid(1:nFit));
target.dx = xGrid(2:end) - xGrid(1:nFit);
target.fGrid = pchip(xFluence',fFluence',target.xGrid')';

% sample the fluence profile densely for plotting:
xFluencePlot = linspace(xBnd(1), xBnd(2), 100);
fFluencePlot = pchip(xFluence',fFluence',xFluencePlot')';

%% Call CMAES
[xMin, fMin, countEval, stopFlag, output, bestEver] = cmaes(...
    'leafTrajFitObj', zGuess, zSigma, options, ...  % standard arguments
    dose, guess, target, param);  % pass through to objective

%% Get the best-ever solution:
[objVal, soln] = leafTrajFitObj(bestEver.x, dose, guess, target, param);

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
ylabel('dose rate')
h.YLim = [0, h.YLim(2)];

subplot(2,2,1); hold on;
plot(soln.target.fGrid, soln.target.xGrid,'rx')
plot(fFluencePlot, xFluencePlot,'r-','LineWidth',1)
plot(soln.target.fSoln, soln.target.xGrid,'k--o','LineWidth',2)
xlabel('fluence dose')
ylabel('position')
legend('Fitting Points','Fluence Target', 'Fluence Soln');
