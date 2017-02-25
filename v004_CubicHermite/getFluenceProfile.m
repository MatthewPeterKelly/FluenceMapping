function [g, x] = getFluenceProfile(tBnd, xBnd, vLow, vUpp, rBnd, drBnd)
% [g, x] = getFluenceProfile(tBnd, xBnd, vLow, vUpp, rBnd, drBnd)
%
% This function computes the fluence profile Gx.
%
% INPUTS:
%   tBnd = [tLow, tUpp] = time bound for problem
%   xBnd = [xLow, xUpp] = position bound for the problem
%   vLow = [vLowA, vLowB] = initial velocity for both plates
%   vUpp = [vUppA, vUppB] = final velocity for both plates
%   rBnd = [rLow, rUpp] = dosage rate at lower and upper bound
%   drBnd = [drLow, drUpp] = dosage accel at lower and upper bound

if nargin == 0
    getFluenceProfile_test();
    return;
end

% Points and weights for gaussian quadrature
gaussPtsUnit = [-0.968160239507626;
    -0.836031107326636;
    -0.613371432700590;
    -0.324253423403809;
    0;
    0.324253423403809;
    0.613371432700590;
    0.836031107326636;
    0.968160239507626];
gaussWeightsUnit = [   0.081274388361574;
    0.180648160694858;
    0.260610696402935;
    0.312347077040003;
    0.330239355001260;
    0.312347077040003;
    0.260610696402935;
    0.180648160694858;
    0.081274388361574];

% Map gaussian points and weights to interval [xLow, xUpp]
xLow = xBnd(1);
xUpp = xBnd(2);
xUnit = 0.5*(1+gaussPtsUnit);
xGrid = xLow + (xUpp - xLow)*xUnit;
wGrid = 0.5*gaussWeightsUnit*(xUpp - xLow);



end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function getFluenceProfile_test()

tBnd = [0,1];
xBnd = [0.1, 4.1];
vLow = [0.2, 0.5];
vUpp = [0.4, 0.3];
rBnd = [0.6, 0.7];
drBnd = [0.8, 0.9];

[g, x] = getFluenceProfile(tBnd, xBnd, vLow, vUpp, rBnd, drBnd);

end
