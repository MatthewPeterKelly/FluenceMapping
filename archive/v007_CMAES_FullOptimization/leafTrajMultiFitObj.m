function [objVal, soln] = leafTrajMultiFitObj(z, dose, guess, target, param)
% This function is a wrapper for fitLeafTrajectories, use by cmaes to
% optimizate over the dose rate profile.
%

nTarget = length(target);
dose.rGrid = z';

% Rate-squared smoothing term
tLow = dose.tGrid(1:(end-1));
tUpp = dose.tGrid(2:end);
rLow = dose.rGrid(1:(end-1));
rUpp = dose.rGrid(2:end);
hSeg = (tUpp - tLow);
vel = (rUpp - rLow)./hSeg;
doseObj = sum(hSeg.*vel.^2);

% Initialize the objective function value
objVal = doseObj*nTarget; 

% Loop over each pair of leaf trajectories
for i=1:nTarget
    soln(i) = fitLeafTrajectories(dose, guess, target(i), param); %#ok<AGROW>
    
    if soln(i).exitFlag == 1  % Optimization succeeded
        
        fitObj = soln(i).obj;     
        
        gamma = param.smooth.doseObjective;
        objVal = objVal + fitObj + gamma*doseObj;
        
    else  % Optimization failed! Skip this point
        
        objVal = NaN;
        
    end
    
end


end