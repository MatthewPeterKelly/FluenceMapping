function J = cubicHermiteIntegral(tLow, tUpp, xLow, xUpp, vLow, vUpp, tLim)
%  J = cubicHermiteIntegral(tLow, tUpp, xLow, xUpp, vLow, vUpp, tLim)
%  J = cubicHermiteIntegral(data, tLim)
%
% Compute the integral of a cubic hermite function on domain tLim

if nargin == 0
    cubicHermiteInterpolate_test();
    return;
end

if nargin == 2
    data = tLow;
    tLim = tUpp;
    tLow = data.tLow;
    tUpp = data.tUpp;
    xLow = data.xLow;
    xUpp = data.xUpp;
    vLow = data.vLow;
    vUpp = data.vUpp;
end

tGrid = [-0.861136311594053;
    -0.339981043584856;
    0.339981043584856;
    0.861136311594053];

wGrid = [0.347854845137454;
    0.652145154862546;
    0.652145154862546;
    0.347854845137454];

tGrid = tLim(1) + (tLim(2) - tLim(1))*0.5*(1+tGrid);  %map to [tLim(1), tLim(2)]
wGrid = 0.5*wGrid*(tLim(2) - tLim(1)); %map to [tLim(1), tLim(2)]
xVal = cubicHermiteInterpolate(tLow, tUpp, xLow, xUpp, vLow, vUpp, tGrid);

J = sum(wGrid.*xVal);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function cubicHermiteInterpolate_test()

tLow = randn(1)  %#ok<NOPRT>
tUpp = tLow + 1.0 + rand(1)  %#ok<NOPRT>
xLow = randn(1)  %#ok<NOPRT>
xUpp = xLow + 0.5 + rand(1)  %#ok<NOPRT>
vLow = 0.1 + rand(1)  %#ok<NOPRT>
vUpp = 0.1 + rand(1)  %#ok<NOPRT>

tLim = sort(rand(1,2));

J = cubicHermiteIntegral(tLow, tUpp, tLow, tUpp, vLow, vUpp, tLim)

t = linspace(tLim(1), tLim(2), 500);
x = cubicHermiteInterpolate(tLow, tUpp, tLow, tUpp, vLow, vUpp, t);
Jcheck = trapz(t,x)

err = (J-Jcheck)/Jcheck

end
