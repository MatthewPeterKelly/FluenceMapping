function C = getPolynomialCoeff(tLow, tUpp, xLow, xUpp, vLow, vUpp)
% C = getPolynomialCoeff(tLow, tUpp, xLow, xUpp, vLow, vUpp)
% C = getPolynomialCoeff(data)
%
% Compute the coefficients of the hermite polynomial so that it can be used
% in functions like roots.m
%

if nargin == 0
    getPolynomialCoeff_test();
    return
end

if nargin == 1
   data = tLow;
   tLow = data.tLow;
   tUpp = data.tUpp;
   xLow = data.xLow;
   xUpp = data.xUpp;
   vLow = data.vLow;
   vUpp = data.vUpp;
end

h = tUpp - tLow;
h1 = 1/h;
h2 = h1*h1;
h3 = h2*h1;

a = 2*h3*(xLow - xUpp) + h2*(vLow + vUpp);  % cubic terms
b = 3*h2*(xUpp - xLow) - h1*(2*vLow + vUpp);  % quadratic terms
c = vLow;  % linear term
d = xLow;
C = [a,b,c,d];

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function getPolynomialCoeff_test()

tLow = randn(1)  %#ok<NOPRT>
tUpp = tLow + 1.0 + rand(1)  %#ok<NOPRT>
xLow = randn(1)  %#ok<NOPRT>
xUpp = randn(1)  %#ok<NOPRT>
vLow = randn(1)  %#ok<NOPRT>
vUpp = randn(1)  %#ok<NOPRT>

C = getPolynomialCoeff(tLow, tUpp, xLow, xUpp, vLow, vUpp);

t = linspace(tLow, tUpp, 100);
x = polyval(C,t-tLow);
xCheck = cubicHermiteInterpolate(tLow, tUpp, xLow, xUpp, vLow, vUpp, t);

figure(14); clf; hold on;

plot(t,x,'LineWidth',4)
plot(t,xCheck,'r--','LineWidth',2)

end