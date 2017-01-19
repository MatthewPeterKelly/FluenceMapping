function z = smoothWindow(xLow, x, xUpp, alpha)
% z = smoothWindow(xLow, x, xUpp, alpha)
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

% TODO:

end