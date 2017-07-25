function alpha = getExpSmoothingParam(frac, width)

% frac:  Fraction of the full change that is to occur over width.
% width: width of the input variable over which the frac change occurs.
%
% eg.   frac = 0.9, width = 0.05
% --> a change from 0.05 to 0.95 occurs between -0.025 and 0.025
%

d = width/2;
f = 0.5*(1+frac);

alpha = -log(1-f)/d;

end