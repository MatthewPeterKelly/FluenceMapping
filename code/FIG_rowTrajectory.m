function [ fig ] = FIG_rowTrajectory(soln, rowi, leafType)
% FIG_rowTrajectory(soln, rowi, leafType) visualizes the trajectories of
% one leaf pair as well as the dose rate pattern in a physical sense
%
% Input:
%   o soln - structure matrix containing the optimization results,
%            where each row corresponds to a leaf pair (see one of the
%            MAIN_*.m files)
%   o rowi - index of the row of interest
%   o leaftype - 1: fixed leaf length, 2: fixed leaf ends
%
% Output:
%   o fig - figure handle (figure displayed)
%
% Note: assumes the time grid is equidistantly spaced and that the dose
% rate and leaf trajecotries are specified on the same grid
%
% TODO: get dmax from soln (asked Matthew sep8)

% Error handling
if nargin == 0
    warning('No inputs specified. Example used.')
    rowi = 1;
    leafType = 2;
    soln.traj.dose = 5 + 3*(rand(1,10)-0.5);
    soln.traj.xLow = [1:0.5:3, 4:0.25:5];
    soln.traj.xUpp = soln.traj.xLow + 2*rand(1,10);
    soln.traj.time = 0:0.5:4.5;
    soln.target.xGrid = 1:7;
    soln.param.limits.position = [1,7];
    dmax = 10;
elseif nargin == 1
    error('Please specify a row index.')
elseif nargin == 2
    leafType = 2;
end

if leafType ~= 1 && leafType ~= 2
    warning('Unkown leaf type. Use "1" for fixed leaf length and "2" for fixed leaf ends. Continued using type "2".')
    leafType = 2;
end

try % Retrieve information
    d = soln(1,rowi).traj.dose;
    xL = soln(1,rowi).traj.xLow;
    xR = soln(1,rowi).traj.xUpp;
    tGrid = soln(1,rowi).traj.time;
    nt = length(tGrid); % number of time steps
    m = length(soln(1,1).target.xGrid); % numer of bixels
    plim = soln(1,rowi).param.limits.position; % treatment field width
    dmax = 10; % ADJUST
catch
    error('Error catched. The input does not have the required format.')
end

% Define some colors
cMGHblue = [0, 139, 176]/255;
cMGHgrey = [98, 99, 101]/255;
cgrey = [192,192,192]/255;

% Setup figure
fig = figure;
hold on
set(fig,'color','w');
colors = colormap('hot');
clims = [0,dmax]; % color range
%fig.Position = [420.00 378.00 500.00 340.00]; % fixed width, perhaps TODO: adjust

% Visualize situation at every time step
for t = 1 : nt
    
    % Plot leaves in this configuration
    l = xL(t);
    r = xR(t);
    if leafType == 1 % Fixed leaf length
        g = min(15,1/4*m); % leaf length
        patch([l-g l l l-g],[t-0.5 t-0.5 t+.5 t+0.5],cgrey); % left leaf
        patch([r r+g r+g r],[t-0.5 t-0.5 t+.5 t+0.5],cMGHgrey); % right leaf
    else % leaftype == 2, fixed leaf ends
        patch([-3 l l -3],[t-0.5 t-0.5 t+.5 t+0.5],cgrey); % left leaf
        patch([r m+4 m+4 r],[t-0.5 t-0.5 t+.5 t+0.5],cMGHgrey); % right leaf
    end
    
    % Color dose rate between leaf ends
    dt = d(t);
    colrt = ceil(dt/dmax*(length(colors)-1)); % determine color
    patch([l r r l],[t-0.5 t-0.5 t+.5 t+0.5],colors(colrt,:));
end

% Extra: plot leaf trajectories as spline
for t = 1 : nt
    scatter(xL(t),t,'filled','FaceColor','k')
    scatter(xR(t),t,'filled','FaceColor','k')
    if t > 1
        line([xL(t-1),xL(t)],[t-1,t],'Color',cMGHblue,'LineStyle','--','LineWidth',2)
        line([xR(t-1),xR(t)],[t-1,t],'Color',cMGHblue,'LineStyle','--','LineWidth',2)
    end
end

% Treatment field boundaries
line([plim(1),plim(1)],[0,nt+1],'Color','k','LineWidth',2) % left bound
line([plim(2),plim(2)],[0,nt+1],'Color','k','LineWidth',2) % right bound

% Figure settings
xlabel('Leaf position (cm)','FontSize',12,'Interpreter','latex')
ylabel('Time (s)','FontSize',12,'Interpreter','latex')
myTitle = ['Trajectory of leaf pair ' num2str(rowi) ' for $T=' num2str(tGrid(nt)) '$ s'];
%myTitle = ['Leaf pair ' num2str(rowi) '. Delivery time = ', num2str(tGrid(nt)) 's'];
title(myTitle,'FontSize',12,'Interpreter','latex')
yticks(1:nt)
yticklabels(tGrid)
if leafType == 1
    axis([plim(1)-g plim(2)+g 0.5 nt+0.5]);
else
    axis([plim(1)-1 plim(2)+1 0.5 nt+0.5]);
end

% Colorbar
nLables = 5;
cTicks = 0 : ceil(dmax / nLables) : dmax;
h = colorbar('Ticks',cTicks);
caxis(clims);
ylabel(h, 'Dose rate (MU/s)','FontSize',12,'Interpreter','latex')

end