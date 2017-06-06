function [xLowGrid, xUppGrid, objVal, exitFlag] = optimizeLeafTrajectories(tGrid, xGrid, doseFun, fluenceFun, options)
% [xLowGrid, xUppGrid, objVal, exitFlag] = optimizeLeafTrajectories(tGrid, xGrid, doseFun, fluenceFun, options)
%
% Given the dose profile and desired fluence profile, compute the best
% possible choice for the lower and upper leaf trajectories
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
    optimizeLeafTrajectories_test();
    return;
end

% Construct an initial guess
xLow = xGrid(1);
xUpp = xGrid(end);
xMid = 0.5*(xLow + xUpp);
xLowGuess = 0.5*(xLow+xMid)*ones(size(tGrid));
xUppGuess = 0.5*(xUpp+xMid)*ones(size(tGrid));
xLeafGuess = [xLowGuess, xUppGuess];

% User-defined objective function:
userFun = @(z)( objFun(z, xGrid, tGrid, doseFun, fluenceFun) );

% Minimize!
[zSoln, objVal, exitFlag] = fminsearch(userFun, xLeafGuess, options);

% Extract the solution:
nTime = length(tGrid);
xLowGrid = zSoln(1:nTime);
xUppGrid = zSoln((nTime+1):end);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function fitErr = objFun(leafGrid, xGrid, tGrid, doseFun, fluenceFun)

nTime = length(tGrid);

xLowGrid = leafGrid(1:nTime);
xUppGrid = leafGrid((nTime+1):end);

fGridTarget = fluenceFun(xGrid);
fGrid = getFluenceProfile(xGrid, tGrid, xLowGrid, xUppGrid, doseFun);

fitErr = sum((fGrid - fGridTarget).^2);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function optimizeLeafTrajectories_test()

nGridT = 4;  % grid on which to evaluate the dose rate
nGridX = 9;  % grid on which to evaluate the fluence
tBnd = [0,2];
tGrid = linspace(tBnd(1),tBnd(2),nGridT);
xBnd = [2, 6];
xGrid = linspace(xBnd(1), xBnd(2), nGridX);

% Compute the sample dose function:
tDose = linspace(tBnd(1), tBnd(2), 5);
rDose = [0.2, 0.8, 0.4, 1.2, 0.3];
ppDose = spline(tDose, rDose);
doseFun = @(t)( ppval(ppDose, t) );

% Compute the sample fluence profile:
xFluence = linspace(xBnd(1), xBnd(2), 5);
gFluence = [0.4, 0.6, 0.8, 1.2, 0.6];
ppFluence = spline(xFluence, gFluence);
fluenceFun = @(x)( ppval(ppFluence, x) );

% Optimization options
options = optimset(...
    'Display','iter',...
    'MaxIter',1000,...
    'TolFun',1e-2,...
    'TolX',1e-2);

% Compute the optimal leaf trajectories:
tic
[xLowGrid, xUppGrid] = optimizeLeafTrajectories(tGrid, xGrid, doseFun, fluenceFun, options);
toc

% Compute the fluence for the solution:
fGrid = getFluenceProfile(xGrid, tGrid, xLowGrid, xUppGrid, doseFun);

figure(2); clf;
plotFluenceFitting(tGrid,xLowGrid,xUppGrid,tGrid,doseFun,xGrid,fGrid, fluenceFun);

end