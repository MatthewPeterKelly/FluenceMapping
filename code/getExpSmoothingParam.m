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

alpha = -log(1-frac)/width;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%


function test_getExpSmoothingParam()

width = 1;
frac = 0.98;

t = width*linspace(-1,1,250);
alpha = getExpSmoothingParam(frac, width);
y = expSigmoid(t,alpha);

figure(32); clf;
plot(t,y);

end