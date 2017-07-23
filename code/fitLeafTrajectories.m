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

xBnd = [min(target.xGrid), max(target.xGrid)];
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
nlpTime = toc(startTime);
[xLow, xUpp] = unpackDecVars(zSoln);
target.fSoln = getFluence(target.xGrid, dose.tGrid, xLow, xUpp, dose.rGrid, alpha, nQuad);

% pack up solution:
soln.traj.xLow = xLow;
soln.traj.xUpp = xUpp;
soln.obj = fSoln;
soln.exitFlag = exitFlag;
soln.nlpTime = nlpTime;
soln.problem = problem;
soln.traj.time = dose.tGrid;
soln.traj.dose = dose.rGrid;
soln.guess = guess;
soln.target = target;
soln.param = param;

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

% Trapezoid rule:
xLow = target.xGrid(1:(end-1));
xUpp = target.xGrid(2:end);
eLow = fErr(1:(end-1));
eUpp = fErr(2:end);
objFit = 0.5*sum((xUpp - xLow).*(eLow + eUpp));

% Rectangle rule:
tA = dose.tGrid(1:(end-1));
tB = dose.tGrid(2:end);
objVelLow = sum((tB - tA).*(vLow.^2));
objVelUpp = sum((tB - tA).*(vUpp.^2));

objSmooth = beta*(objVelLow + objVelUpp);

obj = objFit + objSmooth;
end
