function [A,B,R] = unpackCubicFunctions(tBnd, xBnd, vLow, vUpp, rBnd, drBnd)
% [A,B,R] = unpackCubicFunctions(tBnd, xBnd, vLow, vUpp, rBnd, drBnd)
%
% Utility function to get lower and upper leaf trajectories and does rate
% trajectory.
%
% INPUTS:
%   tBnd = [tLow, tUpp] = time bound for problem
%   xBnd = [xLow, xUpp] = position bound for the problem
%   vLow = [vLowA, vLowB] = initial velocity for both plates
%   vUpp = [vUppA, vUppB] = final velocity for both plates
%   rBnd = [rLow, rUpp] = dosage rate at lower and upper bound
%   drBnd = [drLow, drUpp] = dosage accel at lower and upper bound
%
% OUTPUTS:
%   A = lower leaf
%   B = upper leaf
%   R = dose rate
%

% Map gaussian points and weights to interval [xLow, xUpp]
xLow = xBnd(1);
xUpp = xBnd(2);

% Construct the cubic hermite data for both leaf trajectories:
tLow = tBnd(1);
tUpp = tBnd(2);
A.tLow = tLow;
A.tUpp = tUpp;
B.tLow = tLow;
B.tUpp = tUpp;

A.xLow = xLow;
B.xLow = xLow;
A.xUpp = xUpp;
B.xUpp = xUpp;

A.vLow = vLow(1);
B.vLow = vLow(2);
A.vUpp = vUpp(1);
B.vUpp = vUpp(2);

% Construct the cubic hermite trajectory for the dose rate:
R.tLow = tLow;
R.tUpp = tUpp;
R.xLow = rBnd(1);
R.xUpp = rBnd(2);
R.vLow = drBnd(1);
R.vUpp = drBnd(2);

end
