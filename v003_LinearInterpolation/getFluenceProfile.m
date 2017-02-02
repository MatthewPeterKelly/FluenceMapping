function [g, x] = getFluenceProfile(t, x1, x2, r, xBnd, nx)
% [g, x] = getFluenceProfile(t, x1, x2, r, xBnd, nx)
%
% This function computes the fluence profile Gx.
%
% INPUTS:
%   t = [1, nt] = time grid for x1, x2, and r
%   x1 = [1, nt] = lower leaf position
%   x2 = [1, nt] = upper leaf position
%   r = [1, nt] = dosage rate
%   xBnd = domain for the position
%   nx = number of grid points for Gx
%   alpha = smoothing parameter
%
% OUTPUTS:
%   g = [nx, 1] = fluence as a function of position
%   x = [nx, 1] = position
%
% NOTES:
%   g(x) = integral r(t) dt for all times where x1 < x < x2
%

if nargin == 0
    getFluenceProfile_test();
    return;
end

nt = length(t);
x = linspace(xBnd(1), xBnd(end), nx)';
g = zeros(size(x));

for i=1:nx
    tBnd = getIntegralBounds(t, x1, x(i)*ones(1,nt), x2);
    if ~isempty(tBnd)
        for j=1:size(tBnd(1))
            g(i) = g(i) + getIntegral(tBnd(j,:), t, r);
        end
    end
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function getFluenceProfile_test()

nt = 50;
nx = 90;
tBnd = [0,1];
xBnd = [-1,1];

t = linspace(tBnd(1), tBnd(end),nt);
x1 = linspace(-0.8, 0.6, nt);
x2 = linspace(-0.6, 0.8, nt);
r = 1 + cos(4*pi*t);  %ones(1,nt);

[g, x] = getFluenceProfile(t, x1, x2, r, xBnd, nx);

figure(5234); clf;

subplot(2,2,1); hold on
plot(t,x1,'r','LineWidth',2);
plot(t,x2,'b','LineWidth',2);
xlabel('time');
ylabel('leaf position');
legend('Leaf One','Leaf Two');
title('Optimal Solution')

subplot(2,2,3); hold on;
plot(t,r,'k','LineWidth',2)
xlabel('time')
ylabel('fluence dose')

subplot(2,2,2); hold on;
plot(x, g, 'g-','LineWidth',2);
xlabel('position')
ylabel('fluence')

end