function [g, xGrid, wGrid] = getFluenceProfile(tBnd, xBnd, vLow, vUpp, rBnd, drBnd)
% [g, x, w] = getFluenceProfile(tBnd, xBnd, vLow, vUpp, rBnd, drBnd)
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
%
% OUTPUTS:
%   g = dose received at each point in x
%   x = position grid for dose data
%   w = quadrature weights for computing integral of g(x)
%

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
xUnit = 0.5*(1+gaussPtsUnit);  % map to [0,1]
xGrid = xLow + (xUpp - xLow)*xUnit;  %map to [xLow, xUpp]
wGrid = 0.5*gaussWeightsUnit*(xUpp - xLow); %map to [xLow, xUpp]

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

A.Coeff = getPolynomialCoeff(A);
B.Coeff = getPolynomialCoeff(B);

% Construct the cubic hermite trajectory for the dose rate:
R.tLow = tLow;
R.tUpp = tUpp;
R.xLow = rBnd(1);
R.xUpp = rBnd(2);
R.vLow = drBnd(1);
R.vUpp = drBnd(2);

% Loop over and compute the fluence dose at each point:
nGrid = length(xGrid);
g = zeros(1,nGrid);
for i = 1:nGrid
    % Find the time that the lower trajectory passes this point:
    C = A.Coeff; C(end) = C(end) - xGrid(i);
    tRoot = roots(C); tRoot = tRoot + tLow;
    tRootLow = tRoot(tRoot>tLow & tRoot < tUpp);
    % Find the time that the upper trajectory passes this point:
    C = B.Coeff; C(end) = C(end) - xGrid(i);
    tRoot = roots(C); tRoot = tRoot + tLow;
    tRootUpp = tRoot(tRoot>tLow & tRoot < tUpp);
    % Compute the intergral of the dose rate over this spot:
    tLim = [tRootUpp, tRootLow];
    g(i) = cubicHermiteIntegral(R, tLim);
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function getFluenceProfile_test()

tBnd = [0,1];
xBnd = [0.1, 4.1];
vLow = [0.02, 0.5];
vUpp = [0.4, 0.03];
rBnd = [2.6, 2.7];
drBnd = [0.8, -0.9];

[g, x, w] = getFluenceProfile(tBnd, xBnd, vLow, vUpp, rBnd, drBnd);

end
