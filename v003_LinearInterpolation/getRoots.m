function [tBnd, isPos] = getRoots(t,x)
% [tBnd, isPos] = getRoots(t,x)
%
% Given a function x(t) on a grid, compute the roots assuming linear
% interpolation between the discrete samples. Return a data structure that
% gives the time-span for positive and negative segments.
%
% INPUTS:
%   t = [1, n] = time grid
%   x = [1, n] = position grid
%
% OUTPUTS:
%   tBnd = [m, 2] = [tLow, tUpp] = start and end times for each segment
%   isPos = [m, 1] = true iff the data is positive on the given section.
%

if nargin == 0
    getRoots_test();
    return;
end

k = x > 0;
kLow = k(1:(end-1));
kUpp = k(2:end);

index = 1:length(k);
rootIdx = index(kLow ~= kUpp);

tRootLow = t(rootIdx);
tRootUpp = t(rootIdx + 1);
xRootLow = x(rootIdx);
xRootUpp = x(rootIdx + 1);

% x = A*t + B  --> 0
% xLow = A*tLow + B
% xUpp = A*tUpp + B
% tRoot = -B/A
% A = (xLow - xUpp)./(tLow-tUpp);
% B = xLow - A*tLow;

A = (xRootLow - xRootUpp)./(tRootLow-tRootUpp);
B = xRootLow - A.*tRootLow;
tRoot = -B./A;

% Handle divide-by-zero case:
isNan = isnan(tRoot); tRootMid = 0.5*(tRootLow + tRootUpp);
tRoot(isNan) = tRootMid(isNan);
tRoot = unique([t(1), tRoot, t(end)]);

tBnd = [tRoot(1:(end-1))', tRoot(2:end)'];

tMid = 0.5*(tBnd(:,1) + tBnd(:,2));
isPos = interp1(t',x',tMid') > 0;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function getRoots_test()

t = linspace(0,1,80);
x = 2*sin(25*t) + 3*t - 1;

[tBnd, isPos] = getRoots(t,x);

figure(624); clf; hold on;
plot(t,x,'k-o','LineWidth',2);
for i=1:length(isPos)
    if isPos(i)
        plot(tBnd(i,:),[0,0],'g','LineWidth',3);
    else
        plot(tBnd(i,:),[0,0],'r','LineWidth',3);
    end
end

end