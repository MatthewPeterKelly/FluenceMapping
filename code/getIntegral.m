function g = getIntegral(tBnd, t, f)
% g = getIntegral(tBnd, t, f)
%
% Compute integral(f(t)) on domain tBnd
%
%

if nargin == 0
    getIntegral_test();
    return;
end

if tBnd(1) < t(1)
    g = [];
    disp('tBnd(1) is out of bounds!')
    return;
elseif tBnd(end) > t(end)
    g = [];
    disp('tBnd(2) is out of bounds!')
    return;
end

iMid = t > tBnd(1) & t < tBnd(end);
tMid = t(iMid);
fMid = f(iMid);

tLow = tBnd(1);
fLow = interp1(t',f',tLow);
tUpp = tBnd(end);
fUpp = interp1(t',f',tUpp);

T = [tLow, tMid, tUpp];
F = [fLow, fMid, fUpp];

g = trapz(T,F);
    
end
