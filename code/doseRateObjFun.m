function [objVal, doseFun, xLowGrid, xUppGrid, exitFlag] = doseRateObjFun(rDose, tDose, tGrid, xGrid, fluenceFun)

% Compute the sample dose function:
ppDose = pchip(tDose, rDose);
doseFun = @(t)( ppval(ppDose, t) );

% Optimization options
options = optimset(...
    'Display','off',...
    'MaxIter',500,...
    'TolFun',1e-2,...
    'TolX',1e-2);

% Compute the optimal leaf trajectories:
[xLowGrid, xUppGrid, objVal, exitFlag] = optimizeLeafTrajectories(tGrid, xGrid, doseFun, fluenceFun, options);

end