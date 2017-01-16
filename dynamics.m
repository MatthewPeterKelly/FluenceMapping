function dx = dynamics(~,~,u)
%  dx = dynamics(t,x,u)
%
% INPUTS:
%   t = [1, nTime] = time
%   x = [nState, nTime] = state
%   u = [nControl, nTime] = control 
%
% OUTPUTS:
%   dx = [nState, nTime] = time-derivative of the state
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
% DYNAMICS:
%   (d/dt) x1 = v1
%   (d/dt) x2 = v2
%

dx = u(2:3,:);

end