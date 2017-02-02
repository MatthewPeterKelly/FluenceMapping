function tBnd = getIntegralBounds(t, xLow, xMid, xUpp)
% tBnd = getIntegralBounds(t, xLow, xUpp, xZero)
%
% Compute the time periods where the following identity holds true:
%       xLow(t) < xMid(t) < xUpp
%
% INPUTS:
%   t = [1, n];
%   xLow = [1, n];
%   xMid = [1, n];
%   xUpp = [1, n];
%
% OUTPUTS:
%   tBnd = [m, 2] = [tLow, tUpp] = intervals where condition holds
%

if nargin == 0
    getIntegralBounds_test();
    return;
end

x1 = xMid - xLow;
x2 = xUpp - xMid;

[tBndAll, isPos] = getWindow(t,x1,x2);

tBnd = zeros(size(tBndAll));
idx = 0;
for i=1:length(isPos)
    if (isPos(i))
        idx = idx + 1;
        tBnd(idx,:) = tBndAll(i,:);
    end
end
tBnd = tBnd(1:idx,:);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function getIntegralBounds_test()


t = linspace(0,1,200);
xLow = 2*sin(30*t) + 3*t - 1;
xMid = 1.3*cos(15*t) + 2*t - 0.5;
xUpp = 3*cos(20*t) + 2.5*t - 1.5;

tBnd = getIntegralBounds(t, xLow, xMid, xUpp);

figure(624); clf; hold on;
plot(t,xLow,'b-o','LineWidth',2);
plot(t,xMid,'k-o','LineWidth',2);
plot(t,xUpp,'r-o','LineWidth',2);
for i=1:size(tBnd,1)
    plot(tBnd(i,:),[0,0],'g','LineWidth',3);
end

end