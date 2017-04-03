function [xLowGrid, xUppGrid] = optimizeLeafTrajectories(tGrid, xGrid, doseFun, fluenceFun)
% [xLowGrid, xUppGrid] = optimizeLeafTrajectories(tGrid, xGrid, doseFun, fluenceFun)
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

% fGrid = getFluenceProfile(xGrid, tGrid, xLowGrid, xUppGrid, rFun)

xLowGrid = xGrid(1) + (xGrid(end) - xGrid(1))*(1-0.5*cos(tGrid));

xUppGrid = xGrid(1) + (xGrid(end) - xGrid(1))*(1-0.5*sin(tGrid));

end


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function optimizeLeafTrajectories_test()

nGridT = 4;  % grid on which to evaluate the dose rate
nGridX = 20;  % grid on which to evaluate the fluence
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

% Compute the optimal leaf trajectories:
tic
[xLowGrid, xUppGrid] = optimizeLeafTrajectories(tGrid, xGrid, doseFun, fluenceFun);
toc

% Compute the fluence for the solution:
fGrid = getFluenceProfile(xGrid, tGrid, xLowGrid, xUppGrid, doseFun);

figure(2); clf;
plotFluenceFitting(tGrid,xLowGrid,xUppGrid,tGrid,doseFun,xGrid,fGrid, fluenceFun);

end