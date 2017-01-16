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
% v1 = u(2,:);
% v2 = u(3,:);
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
% The integrand is itself an integral (the objective function contains a
% complicated double integral).   

xCheb  = chebPts(nTime,xBnd(1), xBnd(2));
tLow = bary(xCheb,T1);
tUpp = bary(xCheb,t2);

% Loop over each point in the trajectory to compute integrand:
gx = zeros(1,nTime);
for i=1:nTime
   [tCheb, wCheb] = chebPts(nTime, tLow(i), tUpp(i));
   rCheb = bary(tCheb,r);
   gx(i) =  sum(wCheb.*rCheb);  %Integral from tLow to tUpp of r(t) dt
end

% Now compare fx and gx;
err = gx - fx(xCheb);

% Pack up into the expression for the integrand. Note that we are doing a
% sort of bad thing: integrating err wrt time, even though it is a function
% of position. This works out in the end because we have sampled both the
% same way. It means that the solution will be off by some scalar multiple,
% but this is easily corrected for in a future version of this work.
dObj = err.^2 + invFit;

end