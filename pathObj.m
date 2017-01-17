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
tCheck = chebyshevPoints(nTime,tBnd);
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
[tFit, tFitWeights] = chebyshevPoints(nFit,tBnd); 
x1Fit = chebyshevInterpolate(x1,tFit,tBnd);  % x1(t)
x2Fit = chebyshevInterpolate(x2,tFit,tBnd);  % x2(t)

% Compute the functions to interpolate position back to time:
t1Fit = chebyshevInterpolate(T1,x1Fit,xBnd);  % T1(x1)
t2Fit = chebyshevInterpolate(T2,x2Fit,xBnd);  % T2(x2)

% Compute the penalty for inverse function fitting:
invFit = w*( (tFit - t1Fit).^2 + (tFit - t2Fit).^2 );
invFitSum = sum(tFitWeights.*invFit);

%%%% Now compute the primary objective function:
% The integrand is itself an integral (the objective function contains a
% complicated double integral).   

[xCheb, xChebWeights] = chebyshevPoints(nTime,xBnd);
tLow = chebyshevInterpolate(T1,xCheb,xBnd);
tUpp = chebyshevInterpolate(T2,xCheb,xBnd);

% Loop over each point in the trajectory to compute integrand:
gx = zeros(1,nTime);
for i=1:nTime
    if tLow(i) >= tUpp(i)
        gx(i) = 0.0;   
        warning('Invalid inverse time');
    else
       [tCheb, wCheb] = chebyshevPoints(nTime, [tLow(i), tUpp(i)]);
       rCheb = chebyshevInterpolate(r,tCheb,[tLow(i), tUpp(i)]);
       gx(i) =  sum(wCheb.*rCheb);  %Integral from tLow to tUpp of r(t) dt
    end
end

% Now compare fx and gx;
err = gx - fx(xCheb);
fittingError = sum(xChebWeights.*err);

% Sum up the objective function:
dObj = ones(size(t))*(fittingError + w*invFitSum);

end