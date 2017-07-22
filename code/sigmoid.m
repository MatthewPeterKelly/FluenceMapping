function x = sigmoid(t, gamma)
  x = 1./(1 + exp(-t*gamma));
end