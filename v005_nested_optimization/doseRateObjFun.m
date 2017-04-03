function [objVal, xLowGrid, xUppGrid, exitFlag] = doseRateObjFun(rDose, tDose, tGrid, xGrid, fluenceFun)

% Compute the sample dose function:
ppDose = pchip(tDose, rDose);
doseFun = @(t)( ppval(ppDose, t) );

% Compute the optimal leaf trajectories:
[xLowGrid, xUppGrid, objVal, exitFlag] = optimizeLeafTrajectories(tGrid, xGrid, doseFun, fluenceFun);

end