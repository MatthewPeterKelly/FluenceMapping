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

%%%% NOTES:
%
% This method seems to work reasonably well. If converges to a solution for
% a simple test case.
%
% I see two potential problems with this: First, the convergence is not
% great, indicating that there is still some sort of problem with the way
% that the problem is posed.
%
% The other problem is that the fluence dose is changing rapidly. This is
% ok, but I think that it causes the solution to be slightly non-unique. 
%
% Running with different initial grids seems to generate a variety of
% solutions, which suggest that the solution is non-unique. 
%
% It also looks like there might be an error in the calculation of the
% fluence profile - need to check up on this.
%

clc; clear; 
addpath ~/Git/OptimTraj
addpath ~/Git/chebFun
addpath ~/Git/ChebyshevPolynomials

%% %% Problem parameters:
nGridPos = 80;  % Discretization for position-integral in objective
nGridTime = 90;  % Discretization for time-integral in objective
xLow = -1;
xUpp = 1;
tLow = 0;
tUpp = 1;
rMax = 10;
vMax = 5;
alpha = 0.05;  %smoothing for integral approximation

%%%% Set up a test function to fit:
fx = @(x)( cos(0.5*pi*x) );

%%%% Create a struct with all problem parameters
P = makeStruct(nGridPos, nGridTime,...
    xLow, xUpp, tLow, tUpp, rMax, vMax,fx,alpha);

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
problem.options(1).method = 'trapezoid';
problem.options(1).trapezoid.nGrid = 5;
problem.options(2).method = 'trapezoid';
problem.options(2).trapezoid.nGrid = 11;

%% %% Solve!
soln = optimTraj(problem);

%% %% Plots:

figure(1); clf;

S = soln(end);

tGrid = S.grid.time;
xGrid = S.grid.state;
uGrid = S.grid.control;
[~, Fx, Gx, Xx] = pathObj(tGrid,xGrid,uGrid,P);

t = linspace(tGrid(1), tGrid(end), 4*(length(tGrid)-1)+1);
x = S.interp.state(t);
u = S.interp.control(t);

subplot(2,2,1); hold on
plot(t,x(1,:),'r','LineWidth',2);
plot(t,x(2,:),'b','LineWidth',2);
plot(tGrid,xGrid(1,:),'ro','LineWidth',2);
plot(tGrid,xGrid(2,:),'bo','LineWidth',2);
xlabel('time');
ylabel('leaf position');
legend('Leaf One','Leaf Two');
title('Optimal Solution')

subplot(2,2,3); hold on;
plot(t,u(1,:),'k','LineWidth',2)
plot(tGrid, uGrid(1,:),'ko','LineWidth',2);
xlabel('time')
ylabel('fluence dose')

subplot(2,2,2); hold on;
plot(Xx, Fx, 'k--','LineWidth',2);
plot(Xx, Gx, 'g-','LineWidth',2);
xlabel('position')
ylabel('fluence')
legend('target','estimated')
title('Fluence Fitting')

subplot(2,2,4); hold on;
plot(Xx, Fx-Gx, 'k--','LineWidth',2);
xlabel('position')
ylabel('fluence error')
title('fitting error')
title(['MSE: ' num2str(S.info.objVal)]);


