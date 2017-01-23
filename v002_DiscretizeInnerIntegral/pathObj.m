function dObj = pathObj(t,x,u,P)
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
xGrid = linspace(P.xLow, P.xUpp, nx);

% Compute discretization of position   (for approximating g(x))
rGrid = interp1(t',r',tGrid')';
x1Grid = interp1(t',x1',tGrid')';
x2Grid = interp1(t',x2',tGrid')';

% Rewrite as matricies for vector operations:
R_grid = ones(nx,1)*rGrid;
X1_grid = ones(nx,1)*x1Grid;
X2_grid = ones(nx,1)*x2Grid;
X_grid = xGrid'*ones(1,nt);

% Compute integrals
k = smoothWindow(X1_grid, X_grid, X2_grid, P.alpha);
dt = (tUpp - tLow)/(nt-1);
Gx = dt*sum(k.*R_grid,2);
Fx = P.fx(xGrid');
dx = (P.xUpp - P.xLow)/(nx-1);
err = (Gx-Fx).^2;
Jx = dx*sum(err);

% Convert to an integrand in time to make the solver happy.
dObj = Jx*ones(size(t))/(tUpp-tLow);

end