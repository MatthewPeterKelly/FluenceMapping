function soln = benchmarkSoln(soln)
% 
%
% Evaluate a solution in the limit of a large number of segments in the
% quadrature approximation and no smoothing. Used to verify that numerical
% artifacts are not damaging the results too much.
%
%

blockingFrac = 0.999;
blockingWidth = 0.0001;
alpha = getExpSmoothingParam(blockingFrac, blockingWidth);
nQuad = 250;

% Exact fluence delivered
soln.target.fluence = getFluence(soln.target.xGrid, soln.dose.tGrid, ...
    soln.traj.xLow, soln.traj.xUpp, soln.dose.rGrid, alpha, nQuad);

% Exact fitting error
fErr = (soln.target.fluence - soln.target.fGrid).^2;

% Primary objective
soln.target.fitErr = sum(fErr.*soln.target.dx);

end