function [tBnd, isPos] = getWindow(t,x1,x2)
% [tBnd, isPos] = getWindow(t,x1,x2)
%
% Given a two functions x1(t) and x2(t), compute the periods where both
% functions are positive. The data is interpolated linearly between knots.
%
% INPUTS:
%   t = [1, n] = time grid
%   x1 = [1, n] = position grid
%   x2 = [1, n] = position grid
%
% OUTPUTS:
%   tBnd = [m, 2] = [tLow, tUpp] = start and end times for each segment
%   isPos = [m, 1] = true iff both x1 and x2 are positive on the section.
%

if nargin == 0
    getWindow_test();
    return;
end

tBnd1 = getRoots(t,x1);
tBnd2 = getRoots(t,x2);
tRoot = unique([tBnd1(:); tBnd2(:)]);
tBnd = [tRoot(1:(end-1)), tRoot(2:end)];

tMid = 0.5*(tBnd(:,1) + tBnd(:,2));
isPos1 = interp1(t',x1',tMid') > 0;
isPos2 = interp1(t',x2',tMid') > 0;
isPos = isPos1 & isPos2;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function getWindow_test()

t = linspace(0,1,80);
x1 = 2*sin(25*t) + 3*t - 1;
x2 = 1.3*cos(15*t) + 2*t - 0.5;

[tBnd, isPos] = getWindow(t,x1,x2);

figure(624); clf; hold on;
plot(t,x1,'b-o','LineWidth',2);
plot(t,x2,'k-o','LineWidth',2);
for i=1:length(isPos)
    if isPos(i)
        plot(tBnd(i,:),[0,0],'g','LineWidth',3);
    else
        plot(tBnd(i,:),[0,0],'r','LineWidth',3);
    end
end

end