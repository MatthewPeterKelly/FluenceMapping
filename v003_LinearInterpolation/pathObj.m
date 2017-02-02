function [dObj, Fx, Gx, Xx] = pathObj(t,x,u,P)
% function dObj = pathObj(t,x,u,P)
%
% INPUTS:
%   t = [1, nTime] = time
%   x = [nState, nTime] = state
%   u = [nControl, nTime] = control 
%   P = problem parameters
%
% OUTPUTS:
%   dObj = [1, nTime] = integrand of the objective function
%   Gx = [nx, 1] = Estimated fluence map for the trajectory
%   Fx = [nx, 1] = Desired fluence map for the trajectory
%   Xx = [nx, 1] = test positions for fluence map
%
% STATE:  (each row is scalar)
%   x1 = leaf position
%   x2 = leaf position
%
% CONTROL:
%   r = dosage rate
%   v1 = leaf velocity
%   v2 = leaf velocity
%
% NOTES:
%   minimize integral { f(x) - g(x) }.^2
%   f(x) is given
%   g(x) = integral { r(t)*k(t,x) } 
%       where k(t,x) is xLow(t) < x < xUpp(t)

% Unpack the state and control:   (all functions of time)
x1 = x(1,:);
x2 = x(2,:);
r = u(1,:);

% Parameters:
nx = P.nGridPos;
xBnd = [P.xLow, P.xUpp];

% Compute fluence profile:
[Gx, Xx] = getFluenceProfile(t, x1, x2, r, xBnd, nx);
Fx = P.fx(Xx);

% Compute integral:
dx = (P.xUpp - P.xLow)/(nx-1);
err = (Gx-Fx).^2;
Jx = dx*sum(err);

% Convert to an integrand in time to make the solver happy.
dObj = Jx*ones(size(t))/(P.tUpp-P.tLow);

% Add regularization terms:
dObj = dObj + P.alpha*sum(u.^2,1);

end