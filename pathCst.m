function [c, ceq] = pathCst(~,x,u,P)
% [c, ceq] = pathObj(t,x,u,P)
%
% INPUTS:
%   t = [1, nTime] = time
%   x = [nState, nTime] = state
%   u = [nControl, nTime] = control 
%   P = struct of problem parameters
%
% OUTPUTS:
%   c = inequality constraint
%   ceq =equality constraint
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
%   

% Unpack the state and control:
x1 = x(1,:);
x2 = x(2,:);
r = u(1,:);
v1 = u(2,:);
v2 = u(3,:);
T1 = u(4,:);
T2 = u(5,:);

%%%% T1 - T2 > tTol
cTime = P.tTol + T2 - T1;

%%%% x2 - x1 > xTol
cPos = P.xTol + x1 - x2;

%%%% v1 > vTol,  v2 > vTol
cV1 = P.vTol - v1;
cV2 = P.vTol - v2;

%%%% Pack up the resulting constraints
c = [cTime'; cPos'; cV1'; cV2'];
ceq = [];

end