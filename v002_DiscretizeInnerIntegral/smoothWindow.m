function [z, zBool] = smoothWindow(xLow, x, xUpp, alpha)
% [z, zBool] = smoothWindow(xLow, x, xUpp, alpha)
%
% This function is a smooth approximation to the boolean logic:
%           z = (xLow < x) & (xUpp > x)
%
% The parameter alpha is a positive smoothing parameter, with smaller
% values corresponding to less smoothing.
%
% INPUTS:
%   xLow = [n1, n2] = lower bound for x
%   x    = [n1, n2] = input values for x
%   xUpp = [n1, n2] = upper bound for x
%   alpha = positive scalar smoothing paramter
%
% OUTPUTS:
%   z = [n1, n2] = smoothed output to boolean, on range [0,1]
%

if nargin == 0
    smoothWindow_test();
    return;
end

zBool = zeros(size(x));
zBool(x>xLow & x<xUpp) = 1;

x1 = x-xLow;
x2 = xUpp-x;

k = 1./((xUpp-xLow)*alpha);

z1 = 1./(1+exp(-x1.*k));
z2 = 1./(1+exp(-x2.*k));

z = z1.*z2;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function smoothWindow_test()

n = 250;
xBnd = 10*[-0.1, 0.5];
xPad = 0.5*sum(xBnd) + diff(xBnd)*[-1,1];
xLow = xBnd(1)*ones(1,n);
xUpp = xBnd(2)*ones(1,n);
x = linspace(xPad(1), xPad(2),n);
alpha = 0.03;
[z, zBool] = smoothWindow(xLow, x, xUpp, alpha);

figure(14); clf; hold on;
plot(x,zBool,'--','LineWidth',2);
plot(x,z,'LineWidth',2);
xlabel('x')
ylabel('z = xLow < x < xUpp')
legend('boolean','smooth');

end