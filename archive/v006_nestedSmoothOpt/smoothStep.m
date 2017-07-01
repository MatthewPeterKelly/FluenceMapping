function x = smoothStep(t,alpha)
% x = smoothStep(t,alpha)
%
% This function is a smooth approximation of the step function:
%  t < 0  :   0
%  t > alpha  :  1
%  else  :  smoothly transition from 0 to 1  (second order continuous)
%

if nargin == 0
    smoothStep_test();
    return;
end

x = zeros(size(t));

idxZero = t <= 0.0;
idxOne = t >= alpha;
idxSmooth = ~idxZero & ~idxOne;

x(idxOne) = 1.0;

% Coefficients for a quintic function that has the boundary conditions:
%       x(0) == 0         x(1) == 1
%      dx(0) == 0        dx(1) == 0
%     ddx(0) == 0       ddx(1) == 0
A = 6.0;  % t^5
B = -15.0;  % t^4
C = 10.0;  % t^3
t1 = t(idxSmooth)/alpha;
t2 = t1.*t1;
t3 = t1.*t2;
t4 = t2.*t2;
t5 = t3.*t2;

x(idxSmooth) = A*t5 + B*t4 + C*t3;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function smoothStep_test()

alpha = 0.1;
t = linspace(-alpha, 2*alpha, 250);
x = smoothStep(t, alpha);

figure(5243); clf; hold on;
plot(t,x);
plot(0,0,'ko');
plot(alpha,1,'ko');

end