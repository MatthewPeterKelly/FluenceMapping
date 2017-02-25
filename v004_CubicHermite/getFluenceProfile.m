function [g, xGrid, wGrid,A,B,R] = getFluenceProfile(tBnd, xBnd, vLow, vUpp, rBnd, drBnd)
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

% Get the structs representing each time-series function
[A,B,R] = unpackCubicFunctions(tBnd, xBnd, vLow, vUpp, rBnd, drBnd);

% Get the polynomial coefficients for the leaf trajectories
A.Coeff = getPolynomialCoeff(A);
B.Coeff = getPolynomialCoeff(B);

% Loop over and compute the fluence dose at each point:
tLow = tBnd(1);
tUpp = tBnd(2);
nGrid = length(xGrid);
g = zeros(nGrid,1);
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

tBnd = [0, 3];
xBnd = [2, 6];
vLow = sort(0.1 + rand(1,2), 2, 'ascend');
vUpp = sort(0.1 + rand(1,2), 2, 'descend');
rBnd = rand(1,2);
drBnd = [rand(1), -rand(1)];

[g, x, w] = getFluenceProfile(tBnd, xBnd, vLow, vUpp, rBnd, drBnd);

figure(2); clf;
plot(x,g);

end
