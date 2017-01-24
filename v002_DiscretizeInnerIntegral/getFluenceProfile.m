function [g, x] = getFluenceProfile(t, x1, x2, r, xBnd, nx, alpha)
% [g, x] = getFluenceProfile(t, x1, x2, r, xBnd, nx, alpha)
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

tUpp = t(2:end);
tLow = t(1:(end-1));
h = tUpp - tLow;
for i=1:nx
    tMask = smoothWindow(x1, x(i)*ones(1,nt), x2, alpha);
    
    warning('There is a logical flaw in this integrator')
    
    % AH-HA!   Found the problem: I'm not inverting the linear
    % approximation of the function - I'm inverting the zero order hold,
    % which cases all sorts of bad non-smoothness in the solution. It is
    % critical that we invert the linear interpolation correctly. We
    % essientially need to find all roots of the interpolation (places
    % where it crosses the desired leaf position) and then use this to
    % compute the exact duration that each region is exposed to the
    % radiation. I think that the smoothing will not be necessary then.
    
    rMask = r.*tMask;
    rLow = rMask(1:(end-1));
    rUpp = rMask(2:end);
    g(i) = 0.5*sum(h.*(rLow + rUpp));  % trapezoid rule
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function getFluenceProfile_test()

nt = 30;
nx = 20;
tBnd = [0,1];
xBnd = [-1,1];

t = linspace(tBnd(1), tBnd(end),nt);
x1 = linspace(-0.8, 0.6, nt);
x2 = linspace(-0.6, 0.8, nt);
r = ones(1,nt);

alpha = 0.02;

[g, x] = getFluenceProfile(t, x1, x2, r, xBnd, nx, alpha);

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