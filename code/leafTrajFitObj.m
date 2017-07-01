function [objVal, soln] = leafTrajFitObj(z, dose, guess, target, param)
% This function is a wrapper for fitLeafTrajectories, use by cmaes to
% optimizate over the dose rate profile.
%

dose.rGrid = z'; 
soln = fitLeafTrajectories(dose, guess, target, param);

if soln.exitFlag == 1  % Optimization succeeded
    
    fitObj = soln.obj;
    
    tLow = dose.tGrid(1:(end-1));
    tUpp = dose.tGrid(2:end);
    rLow = dose.rGrid(1:(end-1));
    rUpp = dose.rGrid(2:end);
    doseObj = sum(0.5*(tUpp - tLow).*(rLow + rUpp));
    
    gamma = param.smooth.doseObjective;
    objVal = fitObj + gamma*doseObj;
    
else  % Optimization failed! Skip this point
    objVal = NaN; 
end

end