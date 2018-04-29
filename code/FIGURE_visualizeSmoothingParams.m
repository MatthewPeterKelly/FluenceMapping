function FIGURE_visualizeSmoothingParams()

% This function is used to generate a figure that helps to visualize the
% effect of the leaf-smoothing parameters.

xLowEdge = -1;
xUppEdge = 1;
xBnd = [-2, 2];

frac = 0.95;  % /gamma

widthVec = [0.05, 0.2, 0.5];    % /Delta x
legendNames = {'no smoothing', ...
               ['$\Delta x$ = ' num2str(widthVec(1)) ' cm'],...
               ['$\Delta x$ = ' num2str(widthVec(2)) ' cm'],...
               ['$\Delta x$ = ' num2str(widthVec(3)) ' cm']};            
               
x = linspace(xBnd(1), xBnd(2), 250);

figure(1523); clf; hold on;
setFigureSize('wide-small')
plot([xBnd(1), xLowEdge, xLowEdge, xUppEdge, xUppEdge, xBnd(2)],...
     [0,0,1,1,0,0],'k-', 'LineWidth',2);
for i = 1:length(widthVec)
   width = widthVec(i);
   alpha = getExpSmoothingParam(frac, width);
   yLow = expSigmoid(x - xLowEdge, alpha);
   yUpp = expSigmoid(xUppEdge - x, alpha);
   k = sqrt(yLow .* yUpp);
   plot(x, k, 'LineWidth', 2)
end
legend(legendNames, 'Interpreter','latex');
xlabel('leaf position $x$ (cm)', 'Interpreter','latex')
ylabel('pass-through fraction $k(t,x)$','Interpreter','latex')

save2pdf('FIG_visualize_exponential_smoothing.pdf');

end