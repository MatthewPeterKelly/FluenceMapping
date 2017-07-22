function fGrid = getFluence(xGrid, tGrid, xLow, xUpp, dose, gamma, tGridQuad)
% fGrid = getFluence(xGrid, tGrid, xLow, xUpp, dose, gamma, tGridQuad)
%
% Compute the fluence (fGrid) at each point (xGrid), given the leaf
% positions (xLow and xUpp) and dose rate (dose) as piecewise linear
% functions of time (tGrid). Smoothing parameter gamma is used to smooth
% the leaf blocking dose step function. Numerical integrals are computed
% by sub-sampling the time grid with nSub grid points per segment.
%

if nargin == 0
    getFluence_test();
    return
end

nx = length(xGrid);
nt = length(tGrid);
nq = length(tGridQuad);

% Interpolate the time grid more densely:
doseQuadGrid = interp1(tGrid', dose', tGridQuad')';
xLowQuadGrid = interp1(tGrid', xLow', tGridQuad')';
xUppQuadGrid = interp1(tGrid', xUpp', tGridQuad')';

% if negative, then radiation is blocked
xDelLow = xGrid'*ones(1,nq) - ones(nx,1)*xLowQuadGrid;
xDelUpp = ones(nx,1)*xUppQuadGrid - xGrid'*ones(1,nq);
kLowPass = sigmoid(xDelLow, gamma);
kUppPass = sigmoid(xDelUpp, gamma);
passThrough = kLowPass.*kUppPass;

% compute the dose that passes through at each position and time:
dosePass = passThrough.*(ones(nx,1)*doseQuadGrid);

% Compute the integral using trapezoid quadrature:
tLow = tGridQuad(1:(end-1));
tUpp = tGridQuad(2:end);
h = ones(nx,1)*(tUpp - tLow);
doseLow = dosePass(:, 1:(end-1));
doseUpp = dosePass(:, 2:end);
doseIntegral = 0.5*h.*(doseLow + doseUpp);
fGrid = sum(doseIntegral,2)';

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function getFluence_test()

xBnd = [0, 2];
xGrid = linspace(xBnd(1), xBnd(2), 20);
gamma = 0.05*diff(xBnd);

nTime = 6;
tGrid = linspace(0, 5, nTime);
xLow = 0.0 + 1.7*rand(1, nTime);
xUpp = 0.3 + 1.7*rand(1, nTime);
xUpp(xUpp < xLow) = xLow(xUpp < xLow);
dose = 4*rand(1, nTime);

nSub = 10; % number of sub-segments between each point in tGrid
tGridQuad = subSampleGrid(tGrid, nSub);
tic
fGrid = getFluence(xGrid, tGrid, xLow, xUpp, dose, gamma, tGridQuad);
toc

% Plots!
figure(5234); clf;

subplot(2,2,2); hold on;
plot(tGrid,xLow,'r-o');
plot(tGrid,xUpp,'b-o');
xlabel('time');
ylabel('leaf position');
legend('Leaf One','Leaf Two');

subplot(2,2,4); hold on;
plot(tGrid,dose,'g-o');
xlabel('time')
ylabel('fluence dose')

subplot(2,2,1); hold on;
plot(fGrid,xGrid,'k-o')

end
