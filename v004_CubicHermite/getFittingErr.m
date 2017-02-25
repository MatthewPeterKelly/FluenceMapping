function [fitErr, x,f,g,A,B,R] = getFittingErr(tBnd, xBnd, vLow, vUpp, rBnd, drBnd, dataFun)

if nargin == 0
    getFittingErr_test();
    return;
end

[g, x, w, A, B, R] = getFluenceProfile(tBnd, xBnd, vLow, vUpp, rBnd, drBnd);
f = dataFun(x);
err = f-g;
fitErr = sum(err.*w);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%


function getFittingErr_test()

tBnd = [0, 3];
xBnd = [2, 6];
vLow = sort(0.1 + rand(1,2), 2, 'ascend');
vUpp = sort(0.1 + rand(1,2), 2, 'descend');
rBnd = rand(1,2);
drBnd = [rand(1), -rand(1)];

dataFun = @(x)(  x.^2 );

[fitErr, x,f,g,A,B,R] = getFittingErr(tBnd, xBnd, vLow, vUpp, rBnd, drBnd, dataFun);

plotFluenceFitting(fitErr,x,f,g,A,B,R);

end