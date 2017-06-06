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

tol = 10*eps;

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
    if fLow == 0.0
        xZero = xLow;
    elseif fUpp == 0.0
        xZero = xUpp;
    else
        error('Root must be bracketed in Ridder''s Method!');
    end
end