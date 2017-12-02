function x = expSigmoid(t, alpha)
% x = expSigmoid(t, alpha)
%
% INPUTS:
%   t = input
%   alpha = smoothing parameter
%
% OUTPUTS:
%   x = 1./(1 + exp(-t*alpha));
%       (smoothly varying from 0 to 1)
%

x = 1./(1 + exp(-t*alpha));

end