function x = smoothStep(t,alpha)
% x = smoothStep(t,alpha)
%
% This function is a smooth approximation of the step function:
%  t < 0  :   0
%  t > 0  :   1
%
% INPUTS:
%   t = matrix of function inputs
%   alpha = width of the smooth transition between zero and one
%
% OUTPUTS:
%   x = smooth version of the step function
%
% NOTES:
%   The smoothing is done using a 5th-order polynomial. 
%   The output is has continuous second derivatives.
%   The implementation is vectorized.
%   Transient region is centered on zero.
%

if nargin == 0
    smoothStep_test();
    return;
end

tLow = -0.5*alpha;  % lower transition threshold
tUpp = 0.5*alpha;  % upper transition threshold
x = zeros(size(t));

idxZero = t <= tLow;
idxOne = t >= tUpp;
idxSmooth = ~idxZero & ~idxOne;

x(idxOne) = 1.0;

% Coefficients for a quintic function that has the boundary conditions:
%       x(0) == 0         x(1) == 1
%      dx(0) == 0        dx(1) == 0
%     ddx(0) == 0       ddx(1) == 0
A = 6.0;  % t^5
B = -15.0;  % t^4
C = 10.0;  % t^3
t1 = (t(idxSmooth) -tLow)/(tUpp - tLow);
t2 = t1.*t1;
t3 = t1.*t2;
t4 = t2.*t2;
t5 = t3.*t2;

x(idxSmooth) = A*t5 + B*t4 + C*t3;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function smoothStep_test()

alpha = 0.1;
t = linspace(-1.2*alpha, 1.2*alpha, 150);

figure(5243); clf; hold on;
plot(t,smoothStep(t, alpha));
plot(-alpha/2,0,'ko');
plot(alpha/2,1,'ko');
axis tight

end