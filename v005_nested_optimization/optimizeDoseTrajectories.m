function [doseFun, objVal, exitFlag] = optimizeDoseTrajectories(tGrid, xGrid, fluenceFun)
% [doseFun, objVal, exitFlag] = optimizeDoseTrajectories(tGrid, xGrid, fluenceFun)
%
% Given the time and position grids, compute the dose function that
% delivers the best fluence profile. Outer optimization loop.
%
% INPUTS:
%   tGrid: time grid on which to evaluate the dose integrals
%   xGrid: position grid on which to compare the fluence profile
%   doseFun: dose rate as a function of time
%   fluenceFun: desired fluence as a function of position
%
% OUTPUTS:
%   xLowGrid: lower leaf position
%   xUppGrid: upper leaf position
%

if nargin == 0
    optimizeDoseTrajectories_test();
    return;
end

% Construct an initial guess
tDose = linspace(tGrid(1), tGrid(end), 5)';
guess = 0.6*ones(size(tDose))';
sigma = 0.4;

% User-defined objective function
objFun = 'doseRateObjFun';

% CMAES options:
options = cmaes('defaults');
options.MaxIter = 40;
options.TolX = 0.1;
options.LBounds = zeros(size(tDose));
options.UBounds = ones(size(tDose));
options.DispModulo = 1;
options.LogModulo = 0;

% Call CMAES:
[~, objVal, ~, exitFlag, zBest] = cmaes(objFun, guess, sigma, options,...
                                            tDose, tGrid, xGrid, fluenceFun);

% Compute the dose trajectory
ppDose = pchip(tDose, zBest);
doseFun = @(t)( ppval(ppDose, t) );

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function optimizeDoseTrajectories_test()

nGridT = 4;  % grid on which to evaluate the dose rate
nGridX = 9;  % grid on which to evaluate the fluence
tBnd = [0,2];
tGrid = linspace(tBnd(1),tBnd(2),nGridT)';
xBnd = [2, 6];
xGrid = linspace(xBnd(1), xBnd(2), nGridX)';

% Compute the sample fluence profile:
xFluence = linspace(xBnd(1), xBnd(2), 5);
gFluence = [0.4, 0.6, 0.8, 1.2, 0.6];
ppFluence = spline(xFluence, gFluence);
fluenceFun = @(x)( ppval(ppFluence, x) );

% Compute the optimal dose trajectories:
doseFun = optimizeDoseTrajectories(tGrid, xGrid, fluenceFun);

% Compute the fluence for the solution:
fGrid = getFluenceProfile(xGrid, tGrid, xLowGrid, xUppGrid, doseFun);

figure(3); clf;
plotFluenceFitting(tGrid,xLowGrid,xUppGrid,tGrid,doseFun,xGrid,fGrid, fluenceFun);

end