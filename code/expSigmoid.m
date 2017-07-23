function x = expSigmoid(t, alpha)
% x = expSigmoid(t, alpha)
%
% INPUTS:
%   t = input
%   alpha = smoothing parameter
%
% OUTPUTS:
%   x = 0.5 + 0.5*t./sqrt(t.*t + alpha*alpha)
%       (smoothly varying from 0 to 1)
%

x = 1./(1 + exp(-t*alpha));

end