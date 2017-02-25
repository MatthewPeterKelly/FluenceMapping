function [A, B, mse, exitFlag] =  fitCubicHermitePairToData(t,x)
% [A, B] =  fitCubicHermitePairToData(t,x)
%
% Fit a pair of cubic hermite functions to a data set such that 
% x(t) ~ B - A
% where A and B describe cubic hermite functions.
%

warning('This function does not really seem to work well. Bad idea.');

if nargin == 0
    fitCubicHermitePairToData_test();
    return;
end

%%%% Fit a single cubic to the data first (we'll construct the pair later)

% Initial guess:
vLow = (x(2) - x(1))/(t(2) - t(1));
vUpp = (x(end) - x(end-1))/(t(end) - t(end-1));
zGuess = [x(1); x(end); vLow; vUpp];

% Set up and solve the optimization:
objFun = @(z)( getFittingError(z,t,x) );
[zSoln, mse, exitFlag] = fminsearch(objFun, zGuess);

% Break out into a pair of cubic functions:
A.tLow = t(1);
A.tUpp = t(end);
B.tLow = t(1);
B.tUpp = t(end);
xLow = zSoln(1);
xUpp = zSoln(2);
vLow = zSoln(3);
vUpp = zSoln(4);
if xLow < 0.0
    A.xLow = xLow;
    B.xLow = 0.0;
else
    A.xLow = 0.0;
    B.xLow = xLow;
end
if xUpp < 0.0
    A.xUpp = xUpp;
    B.xUpp = 0.0;
else
    A.xUpp = 0.0;
    B.xUpp = xUpp;
end
A.xLow = min(xLow, 0.0);
B.xLow = max(xLow, 0.0);
A.xUpp = min(xLow, 0.0);
B.xUpp = max(xLow, 0.0);

A.vLow = min(vLow, 0.0);
B.vLow = max(vLow, 0.0);
B.vUpp = min(vUpp, 0.0);
A.vUpp = max(vUpp, 0.0);

% 
% B.xLow = xLow;
% B.xUpp = xUpp;
% B.vLow = vLow;
% B.vUpp = vUpp;
% 
% A.xLow = 0;
% A.xUpp = 0;
% A.vLow = 0;
% A.vUpp = 0;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [mse, err] = getFittingError(z,t,x)

xFit = cubicHermiteInterpolate(t(1), t(end), z(1), z(2), z(3), z(4),t);
err = xFit - x;
mse = mean(err.^2);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function fitCubicHermitePairToData_test()

tData = linspace(0,1,50);
xData = sin(2*pi*tData + 0.1) + 0.2;

[A, B, mse, exitFlag] =  fitCubicHermitePairToData(tData,xData);
mse   %#ok<NOPRT>
exitFlag   %#ok<NOPRT>

[xA, vA] = cubicHermiteInterpolate(A, tData);
[xB, vB] = cubicHermiteInterpolate(B, tData);

figure(7); clf;

subplot(3,1,1); hold on;
plot(tData,xData,'k-','LineWidth',3);
plot(tData,xB - xA,'g-','LineWidth',2);
xlabel('time')
ylabel('value')
legend('data','fit');

subplot(3,1,2); hold on;
plot(tData, xA, 'r-','LineWidth',2);
plot(tData, xB, 'b-','LineWidth',2);
xlabel('time')
ylabel('pos')

subplot(3,1,3); hold on;
plot(tData, vA, 'r-','LineWidth',2);
plot(tData, vB, 'b-','LineWidth',2);
xlabel('time')
ylabel('vel')

end