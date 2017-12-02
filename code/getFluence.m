function fGrid = getFluence(xGrid, tGrid, xLow, xUpp, dose, alpha, nQuad)
% fGrid = getFluence(xGrid, tGrid, xLow, xUpp, dose, alpha, nQuad)
%
% Compute the fluence (fGrid) at each point (xGrid), given the leaf
% positions (xLow and xUpp) and dose rate (dose) as piecewise linear
% functions of time (tGrid). Smoothing parameter gamma is used to smooth
% the leaf blocking dose step function. Numerical integrals are computed 
% using midpoint (rectangle) quadrature with nQuad uniform segments.
%
% INPUTS:
%   xGrid = [1, nx] = grid on which to compute the fluence
%   tGrid = [1, nt] = time grid on which xLow, xUpp, and dose are defined
%   xLow = [1, nt] = lower leaf position at time in tGrid
%   xUpp = [1, nt] = upper leaf position at time in tGrid
%   dose = [1, nt] = dose rate at time in tGrid
%   alpha = scalar smoothing parameter for leaf-blocking model
%   nQuad = number of uniform segments to use in quadrature
% 
% OUTPUTS:
%   fGrid = [1, nx] = fluence delivered to each point in xGrid
%

if nargin == 0
    getFluence_test();
    return
end

nx = length(xGrid);

% Compute the time-grid for quadrature
tQuad = linspace(tGrid(1), tGrid(end), nQuad+1);
tQuadLow = tQuad(1:nQuad);
tQuadUpp = tQuad(2:end);
tQuadMid = 0.5*(tQuadLow + tQuadUpp);
hQuad = tQuadUpp - tQuadLow;

% Evaluate trajectory at quadrature points:
zDataIn = [dose; xLow; xUpp];
zDataOut = interp1(tGrid', zDataIn', tQuadMid')';
doseQuadGrid = zDataOut(1,:);
xLowQuadGrid = zDataOut(2,:);
xUppQuadGrid = zDataOut(3,:);

% Compute leaf blocking at each point:
xDelLow = xGrid'*ones(1, nQuad) - ones(nx,1)*xLowQuadGrid;
xDelUpp = ones(nx,1)*xUppQuadGrid - xGrid'*ones(1, nQuad);
kLowPass = expSigmoid(xDelLow, alpha);
kUppPass = expSigmoid(xDelUpp, alpha);
passThrough = sqrt(kLowPass.*kUppPass);

% compute the dose that passes through at each position and time:
dosePass = passThrough.*(ones(nx,1)*doseQuadGrid);

% Compute the integral using midpoint (rectangle) quadrature:
doseIntegral = (ones(nx,1)*hQuad).*dosePass;
fGrid = sum(doseIntegral,2)';

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function getFluence_test()

xBnd = [0, 2];
nx = 20;  % number of points to compute fluence at
xGrid = linspace(xBnd(1), xBnd(2), nx+1);
xGrid = 0.5*(xGrid(1:(end-1)) + xGrid(2:end));

% Set the smoothing parameter:
width = 0.05*diff(xBnd);
frac = 0.98;
alpha = getExpSmoothingParam(frac, width);

nTime = 5;
tGrid = linspace(0, 5, nTime);

% xLow = 0.0 + 1.7*rand(1, nTime);
% xUpp = 0.3 + 1.7*rand(1, nTime);
% xUpp(xUpp < xLow) = xLow(xUpp < xLow);
% dose = 4*rand(1, nTime);

xLow = [0, 0.2, 0.3, 0.6, 1.1];
xUpp = [0.3, 0.4, 0.6, 1.5, 1.8];
dose = 4 * ones(1, nTime);

nQuad = 500;  % Number of segments for quadrature approximiation
tic
fGrid = getFluence(xGrid, tGrid, xLow, xUpp, dose, alpha, nQuad);
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
