function [fx, xBnd] = loadProfile(filename)
% fx = loadProfile(filename)
%
% Loads a target fluence profile. 

data = load(filename);

fx = @(x)( spline(data.sx, data.sf, x) );
xBnd = data.sx([1,end]);

end