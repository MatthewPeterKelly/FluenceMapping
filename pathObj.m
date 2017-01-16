function dObj = pathObj(t,x,u,fx,w,xBnd,nFit)
% dObj = pathObj(t,x,u,fx,w,xBnd, nFit)
%
% INPUTS:
%   t = [1, nTime] = time
%   x = [nState, nTime] = state
%   u = [nControl, nTime] = control 
%   fx = scalar function to fit
%   w = weight applied to solving inverse function
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
%   T1 = leaf position inverse
%   T2 = leaf position inverse
%
% NOTES:
%   dObj = (gx - fx)^2 + w*(t-T1(x1(t))^2 + w*(t-T2(x2(t))^2
%   fx is given
%   gx = integral r(t) dt from T1(x) to T2(x)
%

% Check that we only use this with the chebyshev method:
tBnd = t([1,end]);
nTime = length(t);
tCheck = chebPts(nTime,tBnd);
if any(abs(tCheck - t) > 1e-12)
    error('This function can only be called with a Chebyshev time grid!');
end

% Unpack the state and control:
x1 = x(1,:);
x2 = x(2,:);
r = u(1,:);
v1 = u(2,:);
v2 = u(3,:);
T1 = u(4,:);
T2 = u(5,:);

%%%% Compute the inverse functions:

% Compute the functions to interpolate each position trajectory:
tFit = chePts(nFit,tBnd);
x1Fit = bary(tFit,x1);
x2Fit = bary(tFit,x2);

% Compute the functions to interpolate position back to time:
t1Fit = bary(x1Fit,T1);
t2Fit = bary(x2Fit,T2);

% Compute the penalty for inverse function fitting:
invFit = w*( (tFit - t1Fit).^2 + (tFit - t2Fit).^2 );

%%%% Now compute the primary objective function:
% Compute the inner integral in this function, then let the software
% compute the outer integral.
%

end