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

z = zBool;  % TODO:  smooth version of this!

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function smoothWindow_test()

n = 100;
xLow = -0.5*ones(1,n);
xUpp = 0.5*ones(1,n);
x = linspace(-1,1,n);
alpha = 0.2;
[z, zBool] = smoothWindow(xLow, x, xUpp, alpha);

figure(14); clf; hold on;
plot(x,zBool,'--');
plot(x,z);

end