% MAIN -- 
%
% Solve the inner integral by representing as a discrete sum
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
% DYNAMICS:
%   (d/dt) x1 = v1
%   (d/dt) x2 = v2
%
% PATH CONSTRAINTs:     (Treated as best-fit soft constraint)
%   x2 - x1 > 0   
%
% BOUNDS:
%   xLow < x1 < xUpp
%   xLow < x2 < xUpp
%   0 < r < rMax
%   -vMax < v1 < vMax
%   -vMax < v2 < vMax
%
% OBJECTIVE:
%   minimize integral (g(x) - f(x))^2
%   f(x) is given
%   g(x) = integral r(t) dt over all times S.T. x1 < x < x2
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~% 


clc; clear; 
addpath ~/Git/OptimTraj
addpath ~/Git/chebFun
addpath ~/Git/ChebyshevPolynomials

%%%% Problem parameters:
nGridTraj = 11;   % Order of the fitting polynomial
nGridPos = 20;  % Discretization for position-integral in objective
nGridTime = 50;  % Discretization for time-integral in objective
xLow = -1;
xUpp = 1;
tLow = 0;
tUpp = 1;
rMax = 10;
vMax = 5;

%%%% Set up a test function to fit:
fx = @(x)( cos(0.5*pi*x) );

%%%% Create a struct with all problem parameters
P = makeStruct(nGridTraj, nGridPos, nGridTime,...
    xLow, xUpp, tLow, tUpp, rMax, vMax,fx);

%%%% Set up the user-defined functions for the optimization:
problem.func.dynamics = @dynamics;
problem.func.pathObj = @(t,x,u)( pathObj(t,x,u,P) );
problem.func.pathCst = @pathCst;

%%%% set up the bounds for the problem:
problem.bounds.initialTime.low = tLow;
problem.bounds.initialTime.upp = tLow;
problem.bounds.finalTime.low = tUpp;
problem.bounds.finalTime.upp = tUpp;
problem.bounds.state.low = [xLow; xLow];
problem.bounds.state.upp = [xUpp; xUpp];
problem.bounds.control.low = [0;-vMax;-vMax];  % [r,v1,v22]
problem.bounds.control.upp = [rMax;vMax;vMax];

%%%% Set up an initial guess:
problem.guess.time = [tLow, tUpp];
x1Guess = (xLow + 0.3*(xUpp-xLow))*[1,1];
x2Guess = (xLow + 0.7*(xUpp-xLow))*[1,1];
problem.guess.state = [x1Guess; x2Guess];
problem.guess.control = zeros(3,2);

%%%% OptimTraj options:
problem.options.method = 'trapezoid';
problem.options.trapezoid.nGrid = nGridTraj;

%%%% Solve!
soln = optimTraj(problem);

