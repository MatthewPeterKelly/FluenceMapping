function soln = benchmarkSoln(soln)
% 
%
% Evaluate a solution in the limit of a large number of segments in the
% quadrature approximation and no smoothing. Used to verify that numerical
% artifacts are not damaging the results too much.
%
%

% Exact fluence delivered
blockingFrac = 0.999;
blockingWidth = 0.0001;
alpha = getExpSmoothingParam(blockingFrac, blockingWidth);
nQuad = 500;
soln.benchmark.xGrid = soln.param.fluenceTargetDense.x;
soln.benchmark.fGrid = getFluence(soln.benchmark.xGrid, ...
    soln.dose.tGrid, soln.traj.xLow, soln.traj.xUpp, soln.dose.rGrid,...
    alpha, nQuad);

% Exact fitting error
soln.benchmark.errGrid = (soln.benchmark.fGrid - soln.param.fluenceTargetDense.f).^2;

% Primary objective
soln.benchmark.fitErr = trapz(soln.param.fluenceTargetDense.x, soln.benchmark.errGrid);
soln.benchmark.fitErrNormalized = soln.benchmark.fitErr/soln.param.fluenceTargetDense.peakFitErr;

% Smooth fluence delivered:
fErr = (soln.target.fGrid - soln.target.fSoln).^2;

% Primary objective
soln.benchmark.objFunFit = sum(fErr .* soln.target.dx);
soln.benchmark.objFunFitNormalized = soln.benchmark.objFunFit / soln.param.fluenceTargetDense.peakFitErr;

end