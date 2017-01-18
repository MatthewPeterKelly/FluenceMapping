function dObj = pathObj(t,x,u,P)
% dObj = pathObj(t,x,u,P)
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
nFit = P.invFitGridCount;
[tFit, tFitWeights] = chebyshevPoints(nFit,tBnd); 
x1Fit = chebyshevInterpolate(x1,tFit,tBnd);  % x1(t)
x2Fit = chebyshevInterpolate(x2,tFit,tBnd);  % x2(t)

% Compute the functions to interpolate position back to time:
T1_domain = x1Fit([1,end]);
T2_domain = x2Fit([1,end]);
t1Fit = chebyshevInterpolate(T1,x1Fit,T1_domain);  % T1(x1)
t2Fit = chebyshevInterpolate(T2,x2Fit,T2_domain);  % T2(x2)

% Compute the penalty for inverse function fitting:
invFit = P.invFitWeight*( (tFit - t1Fit).^2 + (tFit - t2Fit).^2 );
invFitSum = sum(tFitWeights.*invFit);

%%%% Now compute the primary objective function:
% The integrand is itself an integral (the objective function contains a
% complicated double integral).   

xBnd = [max(T1_domain(1), T2_domain(1)), min(T1_domain(2), T2_domain(2))];
[xCheb, xChebWeights]  = chebyshevPoints(nTime,xBnd);
tUpp = chebyshevInterpolate(T1,xCheb,T1_domain);
tLow = chebyshevInterpolate(T2,xCheb,T2_domain);

% Loop over each point in the trajectory to compute integrand:
gx = zeros(1,nTime);
timeDomain = t([1,end]);
for i=1:nTime
    if tLow(i) >= tUpp(i)
        gx(i) = 0.0;   
        warning('Invalid inverse time');
    else
       tmpDomain = [tLow(i) + 0.1*P.tTol, tUpp(i) - 0.1*P.tTol];
       [tCheb, wCheb] = chebyshevPoints(nTime, tmpDomain);
       rCheb = chebyshevInterpolate(r,tCheb,timeDomain);
       gx(i) =  sum(wCheb.*rCheb);  %Integral from tLow to tUpp of r(t) dt
    end
end

% Now compare fx and gx;
err = gx - P.fx(xCheb);
fittingError = sum(xChebWeights.*err);

% Sum up the objective function:
dObj = ones(size(t))*(fittingError + invFitSum);

end