function plotResult(R)

% Plots the result obtained from fitLeafTrajectories.m

tGrid = R.traj.time;
xLow = R.traj.xLow;
xUpp = R.traj.xUpp;
fTarget = R.target.fGrid;
fDelivered = R.target.fSoln;
xGrid = R.target.xGrid;
plotFluence(tGrid, xLow, xUpp, fTarget, fDelivered, xGrid)

end