% MAIN - fluence mapping
%
% Requires OptimTraj toolbox
%
% STATE:  (each row is scalar)
%   x1 = leaf position
%   x2 = leaf position
%   T1 = leaf position inverse
%   T2 = leaf position inverse
%
% CONTROL:
%   u = dosage rate
%   v1 = leaf velocity
%   v2 = leaf velocity
%
% DYNAMICS:
%   (d/dt) x1 = v1
%   (d/dt) x2 = v2
%
% PATH CONSTRAINTs:     (Treated as best-fit soft constraint)
%   0 = t - T1(x1(t))
%   0 = t - T2(x2(t))
%
% BOUNDS:
%   -1 < x1 < 1
%   -1 < x2 < 1
%   0 < T1 < 1
%   0 < T2 < 1
%   0 < u
%   0 < v1
%   0 < v2
%   0 < t < 1
%
% OBJECTIVE:
%   minimize integral (g(x) - f(x))^2
%   f(x) is given
%   g(x) = integral u(t) dt from T1(x) to T2(x)
%

