% This script loads one of the sample fluence-fitting problems and solves
% it using nested optimization with CMAES and FMINCON

%%

clc; clear;

% fileName = 'sampleData/twodips.mat'; figNum = 1025;
fileName = 'sampleData/twohumps.mat';  figNum = 1026;

fluenceTargetData = load(fileName);

tBnd = [0, 10];  % Time
xBnd = [min(fluenceTargetData.sx), max(fluenceTargetData.sx)];   % bounds on leaf position
vBnd = [0, 3];  % bounds on leaf velocity
rBnd = [0, 10]; % bounds on dose rate

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

% Set up the initial guess, limits, and search domain for cmaes
zGuess = dose.rGrid';
zLow = rBnd(1)*ones(nGrid,1);
zUpp = rBnd(2)*ones(nGrid,1);
zSigma = 0.4*(zUpp - zLow);

% Set up the options for CMAES
options = cmaes('defaults');
options.LBounds = zLow;
options.UBounds = zUpp;
options.MaxFunEvals = 200;
options.MaxIter = 25;
options.TolX = 0.01*diff(rBnd);
options.TolFun = 1e-3;
options.EvalInitialX = 'yes';
options.DispModulo = 1;
defaultPopultation = (4 + floor(3*log(nGrid)));
options.PopSize = 3*defaultPopultation;


% Use the default initialization for leaf trajectories for now
guess = [];

% Sample the fluence map:
nFit = 5*nGrid;
xGrid = linspace(xBnd(1), xBnd(2), nFit+1);
xMid = 0.5*(xGrid(1:nFit) + xGrid(2:end));
target.xGrid = xMid;
target.dx = xGrid(2:end) - xGrid(1:nFit);
target.fGrid = interp1(fluenceTargetData.sx', fluenceTargetData.sf', target.xGrid')';

%% Call CMAES
[xMin, fMin, countEval, stopFlag, output, bestEver] = cmaes(...
    'leafTrajFitObj', zGuess, zSigma, options, ...  % standard arguments
    dose, guess, target, param);  % pass through to objective

%% Get the best-ever solution:
[objVal, soln] = leafTrajFitObj(bestEver.x, dose, guess, target, param);

% Plots!
figure(figNum); clf;
tGrid = soln.traj.time;

subplot(2,2,2); hold on;
plot(tGrid, soln.traj.xLow,'r-o');
plot(tGrid, soln.traj.xUpp,'b-o');
xlabel('time');
ylabel('leaf position');
legend('Leaf One','Leaf Two','Location','NorthWest');

fluenceHandle = subplot(2,2,4); hold on;
plot(tGrid, soln.traj.dose, 'g-o');
xlabel('time')
ylabel('dose rate')
fluenceHandle.YLim(1) = 0.0;

subplot(2,2,1); hold on;
plot(soln.target.fGrid, soln.target.xGrid,'rx')
plot(fluenceTargetData.sf, fluenceTargetData.sx,'r-','LineWidth',1);
plot(soln.target.fSoln, soln.target.xGrid,'k--o','LineWidth',2)
xlabel('fluence dose')
ylabel('position')
legend('Fitting Points','Fluence Target', 'Fluence Soln');

% h = subplot(2,2,3); hold on;
% axis off;
% h.XLim = [0,1];
% h.YLim = [0,1];
% dataString = {...
%     ['ObjVal: ' num2str(soln.obj)];
%     ['NLP Time: ' num2str(soln.nlpTime)];
%     ['countEval: ' num2str(countEval)];
%     ['bestEver.f: ' num2str(bestEver.f)];
%     };
% text(0.05, 0.5, dataString, ...
%     'FontSize',14)


