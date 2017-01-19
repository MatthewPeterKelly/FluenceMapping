% MAIN - fluence mapping
%
% Requires OptimTraj toolbox and ChebFun toolbox
%
% STATE:  (each row is scalar)
%   x1 = leaf position
%   x2 = leaf position
%
% CONTROL:
%   r = dosage rate
%   v1 = leaf velocity
%   v2 = leaf velocity
%   T1 = leaf position inverse
%   T2 = leaf position inverse
%
% DYNAMICS:
%   (d/dt) x1 = v1
%   (d/dt) x2 = v2
%
% PATH CONSTRAINTs:     (Treated as best-fit soft constraint)
%   0 = t - T1(x1(t))   % Solve inverse equations
%   0 = t - T2(x2(t))
%   T1 - T2 > tTol    % prevent singularity in integral expression
%   x2 - x1 > xTol   % 
%
%
% BOUNDS:
%   xLow < x1 < xUpp
%   xLow < x2 < xUpp
%   tLow < T1 < tUpp
%   tLow < T2 < tUpp
%   0 < r < rMax
%   0 < v1 < vMax
%   0 < v2 < vMax
%   tLow < t < tUpp
%
% OBJECTIVE:
%   minimize integral (g(x) - f(x))^2
%   f(x) is given
%   g(x) = integral r(t) dt from T1(x) to T2(x)
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~% 

warning('There still seems to be some numerical issue here...');

clc; clear; 
addpath ~/Git/OptimTraj
addpath ~/Git/chebFun
addpath ~/Git/ChebyshevPolynomials

%%%% Problem parameters:
nCheb = 11;   % Order of the fitting polynomial
invFitGridCount = 3*nCheb;  % Number of points for inverse fitting 
invFitWeight = 100;   % Weight on inverse fitting solver
xLow = -1;
xUpp = 1;
tLow = 0;
tUpp = 1;
rMax = 10;
vMax = 5;
xTol = 0.05*(xUpp - xLow);
tTol = 0.05*(tUpp - tLow);
vTol = xTol / tTol;

%%%% Set up a test function to fit:
% f(x) = cos(pi*x/2)
fx = @(x)( cos(0.5*pi*x) );

%%%% Create a struct with all problem parameters
P = makeStruct(nCheb, invFitGridCount,invFitWeight, ...
               xLow,xUpp,tLow,tUpp,rMax,vMax,xTol,tTol,vTol,fx);

%%%% Set up the user-defined functions for the optimization:
problem.func.dynamics = @dynamics;
problem.func.pathObj = @(t,x,u)( pathObj(t,x,u,P) );
problem.func.pathCst = @(t,x,u)( pathCst(t,x,u,P) );

%%%% set up the bounds for the problem:
problem.bounds.initialTime.low = tLow;
problem.bounds.initialTime.upp = tLow+tTol;
problem.bounds.finalTime.low = tUpp-tTol;
problem.bounds.finalTime.upp = tUpp;
problem.bounds.state.low = [xLow; xLow];
problem.bounds.state.upp = [xUpp; xUpp];
problem.bounds.control.low = [0;0;0;tLow;tLow];  % [r,v1,v2,T1,T2]
problem.bounds.control.upp = [rMax;vMax;vMax;tUpp;tUpp];

%%%% Set up an initial guess:
tGuess = [tLow+0.5*tTol, tUpp-0.5*tTol];
problem.guess.time = tGuess;
z0 = [xLow+0.1*xTol;xLow+2*xTol];
zF = [xUpp-2*xTol;xUpp-0.1*xTol];
problem.guess.state = [z0, zF];
vGuess = (xUpp-xLow)/(tUpp-tLow);
u0 = [0.1*rMax; vGuess; vGuess; tLow+0.5*tTol; tLow+0.5*tTol];
uF = [0.1*rMax; vGuess; vGuess; tUpp-0.5*tTol; tUpp-0.5*tTol];
problem.guess.control = [u0,uF];

%%%% OptimTraj options:
problem.options.method = 'chebyshev';
problem.options.chebyshev.nColPts = 9;

%%%% Solve!
soln = optimTraj(problem);

%%%% Plots:




