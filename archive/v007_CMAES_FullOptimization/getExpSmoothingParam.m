function alpha = getExpSmoothingParam(frac, width)

% frac:  Fraction of the full change that is to occur over width.
% width: width of the input variable over which the frac change occurs.
%
% eg.   frac = 0.9, width = 0.05
% --> a change from 0.05 to 0.95 occurs between -0.025 and 0.025
%
% x = 1./(1 + exp(-t*alpha));


if nargin == 0
    test_getExpSmoothingParam;
    return
end

alpha = -2 * log( (1 - frac) / (1 + frac) ) / width;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%


function test_getExpSmoothingParam()

width = 2;
frac = 0.98;

t = 0.5*width*linspace(-1,1,250);
alpha = getExpSmoothingParam(frac, width);
y = expSigmoid(t,alpha);

dy = y(end) - y(1);
fprintf('y(1) - y(-1) = %6.6f\n', dy);
fprintf('error: %6.6g\n',dy - frac);

figure(32); clf;
plot(t,y);

end