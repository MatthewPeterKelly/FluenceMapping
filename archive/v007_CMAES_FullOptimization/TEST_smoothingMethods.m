function TEST_smoothingMethods()
% TEST -- smoothing methods
%
% Compare square and exponential smoothing, and set smoothing parameters
% based on the width of the smoothing.
%
%

frac = 0.98;
width = 0.1;

t = 1.5*width*linspace(-1,1,250);

alpha = setSqrtSmoothingParam(frac, width);
xSqrt = sqrtSigmoid(t, alpha);

gamma = setExpSmoothingParam(frac, width);
xExp = expSigmoid(t, gamma);


d = width/2;
f = 0.5*(1+frac);

figure(3453); clf;
subplot(2,1,1); hold on;
plot(t, xSqrt);
plot(t, xExp);
plot(t, zeros(size(t)),'k--')
plot(t, ones(size(t)),'k--')
plot(d,f,'ko')
plot(-d,1-f,'ko')
legend('sqrt','exp')
title('single leaf blocking')

subplot(2,1,2); hold on;
plot(t, xSqrt.^2);
plot(t, xExp.^2);
plot(t, zeros(size(t)),'k--')
plot(t, ones(size(t)),'k--')
plot(d,f.^2,'ko')
plot(-d,(1-f).^2,'ko')
legend('sqrt^2','exp^2')
title('combined leaf blocking')

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function x = sqrtSigmoid(t, alpha)
% x = sqrtSigmoid(t, alpha)
%
% INPUTS:
%   t = input
%   alpha = smoothing parameter
%
% OUTPUTS:
%   x = 0.5 + 0.5*t./sqrt(t.*t + alpha*alpha)
%       (smoothly varying from 0 to 1)
%

x = 0.5 + 0.5*t./sqrt(t.*t + alpha*alpha);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function alpha = setSqrtSmoothingParam(frac, width)

% frac:  Fraction of the full change that is to occur over width.
% width: width of the input variable over which the frac change occurs.
%
% eg.   frac = 0.9, width = 0.05
% --> a change from 0.05 to 0.95 occurs between -0.025 and 0.025
%

d = width/2;
f = 0.5*(1+frac);

alpha = d*sqrt( 1/(2*f-1)^2 - 1);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function x = expSigmoid(t, gamma)
x = 1./(1 + exp(-t*gamma));
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function gamma = setExpSmoothingParam(frac, width)

% frac:  Fraction of the full change that is to occur over width.
% width: width of the input variable over which the frac change occurs.
%
% eg.   frac = 0.9, width = 0.05
% --> a change from 0.05 to 0.95 occurs between -0.025 and 0.025
%

d = width/2;
f = 0.5*(1+frac);

gamma = -log(1-f)/d;

end
