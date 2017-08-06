function soln = fitLeafTrajectoriesIter(dose, guess, target, param)
% soln = fitLeafTrajectoriesIter(tGrid, guess, target, param)
%
% Calls fitLeafTrajectories() for a sequence of leafBlockingWidth smoothing
% parameters, using each solution to seed the next.
%
%

widthList = param.smooth.leafBlockingWidth;

param.smooth.leafBlockingWidth = widthList(1);
soln(1) = fitLeafTrajectories(dose, guess, target, param);
soln(1) = benchmarkSoln(soln(1));

for iter = 2:length(widthList)
    param.smooth.leafBlockingWidth = widthList(iter);
    guess.tGrid = soln(iter-1).traj.time;
    guess.xLow = soln(iter-1).traj.xLow;
    guess.xUpp = soln(iter-1).traj.xUpp;
    soln(iter) = fitLeafTrajectories(dose, guess, target, param); %#ok<*AGROW>
    soln(iter) = benchmarkSoln(soln(iter)); 
end

end