function [c, ceq] = pathCst(~,x,~)
% [c, ceq] = pathObj(t,x,u)
%
% INPUTS:
%   t = [1, nTime] = time
%   x = [nState, nTime] = state
%   u = [nControl, nTime] = control 
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
%   

% Unpack the state and control:
x1 = x(1,:);
x2 = x(2,:);

% The upper leaf must remain above the lower leaf
cPos = x1-x2;

%%%% Pack up the resulting constraints
c = cPos';
ceq = [];

end