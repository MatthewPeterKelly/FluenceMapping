function [tRoot, vRoot, ppx, ppv] = getPchipRoots(t,x)
% [tRoot, vRoot, ppx, ppv] = getPchipRoots(t,x)
%
% This function computes a PCHIP spline through the data set x(t) and then
% finds the roots of the spline.
%
% INPUTS:
%  t = [1,n] = monotonically increasing vector of time stamps
%  x = [1,n] = data at each time stamp = x(t)
%
% OUTPUTS:
%  tRoot = [1,k] = monotonically increasing vector corresponding to the 
%          time at which each root occurs. Empty if no roots exist.
%  vRoot = [1,k] = derivative of the interpolant at each of the roots.
%  ppx = Matlab pp-form (PCHIP) spline that interpolates x(t)
%  ppv = Matlab pp-form spline that is the derivative of x(t)
%
% NOTES:
%  -- roots are computed numerically using Ridder's Method.
%

if nargin == 0
    getPchipRoots_test();
    return;
end   

nGrid = length(t);
nSeg = nGrid - 1;

ppx = pchip(t,x);
ppv = ppDer(ppx);

% Compute critical segments:
critSeg = false(1,nSeg);
for i=1:nSeg
    if sign(x(i)) ~= sign(x(i+1))
       critSeg(i) = true;
    end    
end
tCritLow = t([critSeg,false]);
tCritUpp = t([false, critSeg]);

% Compute root for each critical segment:
nRoot = sum(critSeg);
tRoot = zeros(1,nRoot);
userFun = @(t)( ppval(ppx,t) );
for i=1:nRoot
   tLow = tCritLow(i);
   tUpp = tCritUpp(i);
   tRoot(i) = rootSolve(userFun, tLow, tUpp);
end

vRoot = ppval(ppv, tRoot);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function xZero = rootSolve(func,xLow,xUpp)
% XZERO = ROOTSOLVE(FUNC, XLOW, XUPP)
%
% FUNCTION: This function uses Ridder's Method to return a root, xZero,
%     of func on the interval [xLow,xUpp]
%
% INPUTS:
%   func = a function for a SISO function: y = f(x)
%   xLow = the lower search bound
%   xUpp = the upper search bound
%
% OUTPUTS:
%   xZero = the root of the function on the domain [xLow, xUpp]
%
% NOTES:
%   1) The function must be smooth
%   2) sign(f(xLow)) ~= sign(f(xUpp))
%   3) This function will return a root if one exists, and the function is
%   not crazy. If there are multiple roots, it will return the first one
%   that it finds.

maxIter = 50;
fLow = feval(func,xLow);
fUpp = feval(func,xUpp);
xZero = [];

tol = 1e-8;

if (fLow > 0.0 && fUpp < 0.0) || (fLow < 0.0 && fUpp > 0.0)
    for i=1:maxIter
        xMid = 0.5*(xLow+xUpp);
        fMid = feval(func,xMid);
        s = sqrt(fMid*fMid - fLow*fUpp);
        if s==0.0, break; end
        xTmp = (xMid-xLow)*fMid/s;
        if fLow >= fUpp
            xNew = xMid + xTmp;
        else
            xNew = xMid - xTmp;
        end
        xZero = xNew;
        fNew = feval(func,xZero);
        if abs(fNew)<tol, break; end
        
        %Update
        if sign(fMid) ~= sign(fNew)
            xLow = xMid;
            fLow = fMid;
            xUpp = xZero;
            fUpp = fNew;
        elseif sign(fLow) ~= sign(fNew)
            xUpp = xZero;
            fUpp = fNew;
        elseif sign(fUpp) ~= sign(fNew)
            xLow = xZero;
            fLow = fNew;
        else
            error('Something bad happened in riddersMethod!');
        end
        
    end
else
    if abs(fLow) < tol
        xZero = xLow;
    elseif abs(fUpp) < tol
        xZero = xUpp;
    else
        error('Root must be bracketed in Ridder''s Method!');
    end
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function dpp = ppDer(pp)
% dpp = ppDer(pp)
%
% Computes the time-derivative of piece-wise polynomial (PP) struct
%
% INPUTS:
%   pp = a PP struct containing a trajectory of interest
% 
% OUTPUTS:
%   dpp = a new PP struct that is the time-derivative of pp
%
% NOTES:
%   --> a pp struct is typically created by matlab functions such as
%   spline, pchip, or pwch and evaluated using ppval.
%   --> Call this function without arguments to run a test case
%

if nargin == 0
    ppDer_test();
    return;
end

n = pp.order;
nRows = size(pp.coefs,1);
dpp.form = pp.form;
dpp.breaks = pp.breaks;
dpp.coefs = zeros(nRows,n-1);
for i=1:n-1
   dpp.coefs(:,i) = (n-i)*pp.coefs(:,i);
end
dpp.pieces = pp.pieces;
dpp.order = pp.order-1;
dpp.dim = pp.dim;
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function getPchipRoots_test()

nKey = 1 + randi(9,1);

tBnd(1) = 2*randn(1);
tBnd(2) = tBnd(1) + 0.5 + 2*rand(1);

tKey = linspace(tBnd(1), tBnd(2), nKey);
xKey = randn(1,nKey);

tic
[tRoot, vRoot, ppx, ppv] = getPchipRoots(tKey,xKey);
toc
vKey = ppval(ppv,tKey);

t = linspace(tBnd(1), tBnd(2), 200);
x = ppval(ppx,t);
v = ppval(ppv,t);

figure(5); clf;

subplot(2,1,1); hold on;
plot(tBnd,[0,0],'k--','LineWidth',1);
plot(t,x,'LineWidth',2);
plot(tKey, xKey,'bo','LineWidth',2,'MarkerSize',8);
plot(tRoot, zeros(size(tRoot)),'rx','LineWidth',2,'MarkerSize',8);
xlabel('time')
ylabel('position')
title('PCHIP interpolation with root solve')

subplot(2,1,2); hold on;
plot(t,v,'LineWidth',2);
plot(tKey, vKey,'bo','LineWidth',2,'MarkerSize',8);
plot(tRoot, vRoot,'rx','LineWidth',2,'MarkerSize',8);
xlabel('time')
ylabel('velocity')

end