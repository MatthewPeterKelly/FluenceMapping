function soln = fitLeafTrajectoriesIter(dose, guess, target, param)
% soln = fitLeafTrajectoriesIter(tGrid, guess, target, param)
%
% Calls fitLeafTrajectories() for a sequence of leafBlockingWidth smoothing
% parameters, using each solution to seed the next.
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
%   param.smooth.leafBlockingWidth = [1, n] = vector of widths over which smoothing occurs
%   param.smooth.leafBlockingFrac = total change over width (eg. 0.98)
%   param.smooth.velocityObjective = velocity-squared objective weight
%   param.nQuad = number of sub-samples to use for quadrature
%   param.guess.defaultLeafSpaceFraction = 0.25;
%   param.fmincon = optimset('fmincon') = options to pass to fmincon
%
%

widthList = param.smooth.leafBlockingWidth;

param.smooth.leafBlockingWidth = widthList(1);
soln(1) = fitLeafTrajectories(dose, guess, target, param);
if soln(1).exitFlag < 0  % Then optimization failed. Abort.
    soln = NaN;
    return;
end

for iter = 2:length(widthList)
    param.smooth.leafBlockingWidth = widthList(iter);
    guess.tGrid = soln(iter-1).traj.time;
    guess.xLow = soln(iter-1).traj.xLow;
    guess.xUpp = soln(iter-1).traj.xUpp;
    soln(iter) = fitLeafTrajectories(dose, guess, target, param); %#ok<*AGROW>
    if soln(iter).exitFlag < 0  % Then optimization failed. Abort.
        soln = NaN;
        return;
    end
end

end