function alpha = getExpSmoothingParam(frac, width)

% frac:  Fraction of the full change that is to occur over width.
% width: width of the input variable over which the frac change occurs.
%
% eg.   frac = 0.9, width = 0.05
% --> a change from 0.05 to 0.95 occurs between -0.025 and 0.025
%

if nargin == 0
    test_getExpSmoothingParam;
    return
end

d = width/2;
f = 0.5*(1+frac);

alpha = -log(1-f)/d;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%


function test_getExpSmoothingParam()

width = 0.1;
frac = 0.0;

t = width*linspace(-1,1,250);
alpha = getExpSmoothingParam(frac, width);
y = expSigmoid(t,alpha);

delY = y(end) - y(1)

figure(32); clf;
plot(t,y);

end