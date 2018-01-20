function soln = fitLeafTrajectories(dose, guess, target, param)
% soln = fitLeafTrajectories(tGrid, guess, target, param)
%
% Compute the fluence to approximate the target fluence profile:
%
% INPUTS:
%   dose.tGrid = [1, nGrid] = time-grid for radiation dose-rate profile
%   dose.rGrid = [1, nGrid] = radiation dose-rate profile
%   guess.tGrid = [1, nGuess] = time-grid for guess
%   guess.xLow = [1, nGuess] = lower-leaf position at each point in tGrid
%   guess.xUpp = [1, nGuess] = upper-leaf position at each point in tGrid
%   target.xGrid = [1, nFit] = time grid for fitting function
%   target.fGrid = [1, nFit] = fluence at each grid point
%   param.limits.velocity = [low, upp] = lower and upper limits on velocity
%   param.smooth.leafBlockingWidth = width over which smoothing occurs
%   param.smooth.leafBlockingFrac = total change over width (eg. 0.98)
%   param.smooth.velocityObjective = velocity-squared objective weight
%   param.nQuad = number of sub-samples to use for quadrature
%   param.guess.defaultLeafSpaceFraction = 0.25;
%   param.fmincon = optimset('fmincon') = options to pass to fmincon
global CPU_TIMES OBJ_VALUE OBJ_EXACT ITER_COUNT
global BEST_EVER_OBJ BEST_EVER_IDX BEST_EVER_DEC_VAR
global DIAGNOSTIC_TIME
CPU_TIMES = zeros(1000,1);
OBJ_VALUE = zeros(1000,1);
OBJ_EXACT = zeros(1000,1);
ITER_COUNT = 0;
BEST_EVER_OBJ = inf;
BEST_EVER_IDX = 0;
BEST_EVER_DEC_VAR = [];
DIAGNOSTIC_TIME = 0;  % How long we spend checking the exact objective function value

xBnd = param.limits.position;
vBnd = param.limits.velocity;

% Use default guess if empy
if isempty(guess)
    frac = param.guess.defaultLeafSpaceFraction;
    guess.tGrid = [dose.tGrid(1), dose.tGrid(end)];
    guess.xLow = [xBnd(1),   xBnd(2) - frac*diff(xBnd)];
    guess.xUpp = [xBnd(1)+ frac*diff(xBnd),   xBnd(2)];
end

% Interpolate the guess to get the initial leaf trajectories.
nTime = length(dose.tGrid);
xLowGuess = interp1(guess.tGrid', guess.xLow', dose.tGrid')';
xUppGuess = interp1(guess.tGrid', guess.xUpp', dose.tGrid')';

% Bounds and initialization:
xLow = xBnd(1)*ones(1, nTime);
xUpp = xBnd(2)*ones(1, nTime);
vLow = vBnd(1)*ones(1, nTime-1);
vUpp = vBnd(2)*ones(1, nTime-1);
zLow = packDecVars(xLow, xLow);
zUpp = packDecVars(xUpp, xUpp);
zGuess = packDecVars(xLowGuess, xUppGuess);

% Constraint: xLow - xUpp <= 0
Aineq_xLim = [diag(ones(nTime,1)), diag(-ones(nTime,1))];
bineq_xLim = zeros(nTime,1);

% Constraint: -hSeg*diff(xLow) <= -vLow   ;   hSeg*diff(xLow) <= vUpp
nSeg = nTime-1;
hSeg = diff(dose.tGrid);
diffMat = [zeros(nSeg,1), eye(nSeg)] - [eye(nSeg), zeros(nSeg,1)];
Aineq_vLow = [-diffMat, zeros(nSeg, nTime);
    diffMat, zeros(nSeg, nTime)];
bineq_vLow = [-(vLow.*hSeg)';
    (vUpp.*hSeg)'];

% Constraint: -hSeg*diff(xUpp) <= -vLow   ;   hSeg*diff(xLow) <= vUpp
diffMat = [zeros(nSeg,1), eye(nSeg)] - [eye(nSeg), zeros(nSeg,1)];
Aineq_vUpp = [zeros(nSeg, nTime), -diffMat;
    zeros(nSeg, nTime), diffMat];
bineq_vUpp = [-(vLow.*hSeg)';
    (vUpp.*hSeg)'];

% Inequality constraint:
Aineq = [Aineq_xLim; Aineq_vLow; Aineq_vUpp];
bineq = [bineq_xLim; bineq_vLow; bineq_vUpp];

% Set the smoothing term for the leaf blocking
param.smooth.leafBlockingAlpha = getExpSmoothingParam(param.smooth.leafBlockingFrac, param.smooth.leafBlockingWidth);
alpha = param.smooth.leafBlockingAlpha;
nQuad = param.nQuad;

% Check to see if we should use diagnostics:
if isfield(param,'diagnostics')
    timer = tic;
    param.fmincon.OutputFcn = @(x, val, state)( fluenceFittingObjectiveExact(x, val, dose, target, param, timer) );
end

% Set up for fmincon:
problem.objective = @(z)( fluenceFittingObjective(z, dose, target, param) );
problem.x0 = zGuess;
problem.Aineq = Aineq;
problem.bineq = bineq;
problem.Aeq = [];
problem.beq = [];
problem.lb = zLow;
problem.ub = zUpp;
problem.nonlcon = [];
problem.solver = 'fmincon';
problem.options = param.fmincon;

% solve:
startTime = tic;
[zSoln, fSoln, exitFlag] = fmincon(problem);
solveTime = toc(startTime);  % time spent in during the solve
nlpTime = solveTime - DIAGNOSTIC_TIME;  % time spent in fmincon
if isfield(param, 'diagnostics')
    % Use the best-ever solution
    fSoln = BEST_EVER_OBJ;
    zSoln = BEST_EVER_DEC_VAR;
    % Compute the fluence using the (nearly) exact model:
    nQuad = param.diagnostics.nQuad;
    alpha = param.diagnostics.alpha;
end
[xLow, xUpp] = unpackDecVars(zSoln);
target.fSoln = getFluence(target.xGrid, dose.tGrid, xLow, xUpp, dose.rGrid, alpha, nQuad);

% pack up solution:
soln.traj.xLow = xLow;
soln.traj.xUpp = xUpp;
soln.obj = fSoln;
soln.exitFlag = exitFlag;
soln.solveTime = solveTime;
soln.nlpTime = nlpTime;
soln.problem = problem;
soln.traj.time = dose.tGrid;
soln.traj.dose = dose.rGrid;
soln.guess = guess;
soln.dose = dose;
soln.target = target;
soln.param = param;
soln.diagnostics.cpuTime = CPU_TIMES(1:ITER_COUNT);
soln.diagnostics.objVal = OBJ_VALUE(1:ITER_COUNT);
soln.diagnostics.objExact = OBJ_EXACT(1:ITER_COUNT);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [xLow, xUpp] = unpackDecVars(z)

nGrid = length(z)/2;
idx = 1:nGrid;
xLow = z(idx)';
idx = idx(end) + (1:nGrid);
xUpp = z(idx)';

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function z = packDecVars(xLow, xUpp)

z = [xLow, xUpp]';

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function stop = fluenceFittingObjectiveExact(zGuess, objVal, dose, target, param, timer)
% [obj, cpuTime] = fluenceFittingObjectiveExact(zGuess, objVal, dose, target, param)
%
% Compute the objective function, but set alpha to a very small value and
% use a large number of quadrature points. The result is an accurate
% estimate of the fluence that would be delivered by the exact model.
%
global CPU_TIMES OBJ_VALUE OBJ_EXACT ITER_COUNT
global BEST_EVER_OBJ BEST_EVER_IDX BEST_EVER_DEC_VAR
global DIAGNOSTIC_TIME

diagnosticTimeStart = tic();
param.nQuad = param.diagnostics.nQuad;
param.smooth.leafBlockingAlpha = param.diagnostics.alpha;
objExact = fluenceFittingObjective(zGuess, dose, target, param);

% Save the data:
ITER_COUNT = ITER_COUNT + 1;
CPU_TIMES(ITER_COUNT) = toc(timer);
OBJ_VALUE(ITER_COUNT) = objVal.fval;
OBJ_EXACT(ITER_COUNT) = objExact;

% Record the best-ever solution:
if objExact < BEST_EVER_OBJ
   BEST_EVER_OBJ =  objExact;
   BEST_EVER_IDX = ITER_COUNT;
   BEST_EVER_DEC_VAR = zGuess;
end

% Decide if we should abort (check convergence to true obj. val)
idxFail = 1.5 * BEST_EVER_IDX + 25;  % heuristic!!
stop = ITER_COUNT > idxFail;
DIAGNOSTIC_TIME = DIAGNOSTIC_TIME + toc(diagnosticTimeStart);
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [obj, fGrid] = fluenceFittingObjective(zGuess, dose, target, param)
% [obj, fGrid] = fluenceFittingObjective(zGuess, dose, target, param)
%
% Compute the mean-squared error for the fluence produced by the inputs
%
% INPUTS:
%   dose.tGrid = [1, nGrid] = time-grid for radiation dose-rate profile
%   dose.rGrid = [1, nGrid] = radiation dose-rate profile
%   target.xGrid = [1, nFit] = time grid for fitting function
%   target.fGrid = [1, nFit] = fluence at each grid point
%   param.limits.velocity = [low, upp] = lower and upper limits on velocity
%   param.smooth.leafBlockingAlpha = smoothing parameter for leaf-blocking model
%   param.smooth.velocityObjective = velocity-squared objective weight
%   param.nQuad = number of segments to use for quadrature
%

[xLow, xUpp] = unpackDecVars(zGuess);

tGrid = dose.tGrid;
hSeg = diff(tGrid);
vLow = diff(xLow)./hSeg;
vUpp = diff(xUpp)./hSeg;

alpha = param.smooth.leafBlockingAlpha;
beta = param.smooth.velocityObjective;
nQuad = param.nQuad;

fGrid = getFluence(target.xGrid, dose.tGrid, xLow, xUpp, dose.rGrid, alpha, nQuad);
fErr = (fGrid - target.fGrid).^2;

% Primary objective
objFit = sum(fErr.*target.dx);

% Secondary objective:  (rectangle rule):
tA = dose.tGrid(1:(end-1));
tB = dose.tGrid(2:end);
objVelLow = sum((tB - tA).*(vLow.^2));
objVelUpp = sum((tB - tA).*(vUpp.^2));

% Combine objective terms
objSmooth = beta*(objVelLow + objVelUpp);

obj = objFit + objSmooth;
end
