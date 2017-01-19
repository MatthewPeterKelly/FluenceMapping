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

% Unpack the state and control:
x1 = x(1,:);
x2 = x(2,:);
r = u(1,:);

% Parameters:
nx = P.nGridPos;
nt = P.nGridTime;

warning('This function is incomplete')

% TODO:  This implementation is close, but not quite right. I'm pretty sure
% that it will work though. There are two changes to be made. First, we
% will need to replace the boolean mask with a smoooth mask. This can be
% done by multiplying the result of two smooth functions, one for the upper
% bound and one for the lower bound. The functions can operate on the x1-x
% and x2-x values. Next, I need to make sure that the discretization logic
% is right. I think that there is a small bug in how I'm breaking up the
% double integral.

% TODO: implement the function smoothWindow() below:
test = smoothWindow(xLow,x,xUpp,alpha);

% Discretization:
tLow = t(1); tUpp = t(end);
tGrid = linspace(tLow, tUpp, nt);
xGrid = linspace(P.xLow, P.xUpp, nx);

% Interpolate trajectory:
rGrid = interp1(t',r',tGrid')';
x1Grid = interp1(t',x1',tGrid')';
x2Grid = interp1(t',x2',tGrid')';

% Build a big matrix for the double integral:
X1 = ones(nt,1)*x1Grid;
X2 = ones(nt,1)*x2Grid;
X = ones(nt,1)*xGrid;
R = rGrid'*ones(1,nx);

% Remove elements that are blocked by leaves
% TODO:  replace this with a smooth approximation of the if statement
mask = true(size(R));
mask(X<X1) = false;
mask(X>X2) = false;
R(~mask) = 0; 

% Compute the inner integral
dt = (tUpp-tLow)/nt;
Gx = dt*sum(R,1);
Fx = P.fx(xGrid);

% Compute the outer integral
dx = (xUpp-xLow)/nx;
fitErr = dx*sum((Fx-Gx).^2);

% Convert to an integrand in time to make the solver happy.
dObj = fitErr*ones(size(t))/(tUpp-tLow);

end