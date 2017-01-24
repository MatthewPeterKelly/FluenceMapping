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
nt = P.nGridTime;

% Discretization:  (for approximating g(x))
tLow = t(1); tUpp = t(end);
tGrid = linspace(tLow, tUpp, nt);
Xx = linspace(P.xLow, P.xUpp, nx);

% Compute discretization of position   (for approximating g(x))
rGrid = interp1(t',r',tGrid')';
x1Grid = interp1(t',x1',tGrid')';
x2Grid = interp1(t',x2',tGrid')';

% Rewrite as matricies for vector operations:
R_grid = ones(nx,1)*rGrid;
X1_grid = ones(nx,1)*x1Grid;
X2_grid = ones(nx,1)*x2Grid;
X_grid = Xx'*ones(1,nt);

% Compute integrals
k = smoothWindow(X1_grid, X_grid, X2_grid, P.alpha);
dt = (tUpp - tLow)/(nt-1);
Gx = dt*sum(k.*R_grid,2);
Fx = P.fx(Xx');
dx = (P.xUpp - P.xLow)/(nx-1);
err = (Gx-Fx).^2;
Jx = dx*sum(err);

warning('There is a logical flaw in this integrator')

% AH-HA!   Found the problem: I'm not inverting the linear
% approximation of the function - I'm inverting the zero order hold,
% which cases all sorts of bad non-smoothness in the solution. It is
% critical that we invert the linear interpolation correctly. We
% essientially need to find all roots of the interpolation (places
% where it crosses the desired leaf position) and then use this to
% compute the exact duration that each region is exposed to the
% radiation. I think that the smoothing will not be necessary then.

% Convert to an integrand in time to make the solver happy.
dObj = Jx*ones(size(t))/(tUpp-tLow);

end