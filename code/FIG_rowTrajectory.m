function [ fig ] = FIG_rowTrajectory(R, leafType)
% FIG_rowTrajectory(R, leafType) visualizes the trajectories of
% one leaf pair as well as the dose rate pattern in a physical sense
%
% Input:
%   o R - structure matrix containing the optimization results,
%         (see one of the MAIN_*.m files)
%   o leaftype - 1: fixed leaf length, 2: fixed leaf ends
%
% Output:
%   o fig - figure handle (figure displayed)
%
% Note: assumes the time grid is equidistantly spaced and that the dose
% rate and leaf trajecotries are specified on the same grid

% Error handling
if nargin == 0
    warning('No inputs specified. Example used.')
    leafType = 2;
    R(1).traj.dose = 5 + 3*(rand(1,10)-0.5);
    R(1).traj.xLow = [1:0.5:3, 4:0.25:5];
    R(1).traj.xUpp = R(1).traj.xLow + 2*rand(1,10);
    R(1).traj.time = 0:0.5:4.5;
    R(1).target.xGrid = 1:7;
    R(1).param.limits.position = [1,7];
    R(1).param.limits.doseRate = [0,10];
elseif nargin == 1
    leafType = 2;
end

if leafType ~= 1 && leafType ~= 2
    warning('Unkown leaf type. Use "1" for fixed leaf length and "2" for fixed leaf ends. Continued using type "2".')
    leafType = 2;
end

try % Retrieve information
    d = R(end).traj.dose;
    xL = R(end).traj.xLow;
    xR = R(end).traj.xUpp;
    tGrid = R(end).traj.time;
    nt = length(tGrid); % number of time steps
    m = length(R(end).target.xGrid); % numer of bixels
    plim = R(end).param.limits.position; % treatment field width
    dmax = R(end).dose.rGrid(1); % constant maximum dose rate
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
    if colrt > 0
        thecol = colors(colrt,:);
    else
        thecol = [0,0,0]; % black
    end
    patch([l r r l],[t-0.5 t-0.5 t+.5 t+0.5],thecol);
end

% Extra: plot leaf trajectories as spline
for t = 1 : nt
    scatter(xL(t),t,'filled','MarkerFaceColor','k')
    scatter(xR(t),t,'filled','MarkerFaceColor','k')
    if t > 1
        line([xL(t-1),xL(t)],[t-1,t],'Color',cMGHblue,'LineStyle','--','LineWidth',2)
        line([xR(t-1),xR(t)],[t-1,t],'Color',cMGHblue,'LineStyle','--','LineWidth',2)
    end
end

% Treatment field boundaries
line([plim(1),plim(1)],[0,nt+1],'Color','k','LineWidth',2) % left bound
line([plim(2),plim(2)],[0,nt+1],'Color','k','LineWidth',2) % right bound

% Figure settings
xlabel('leaf position (cm)','FontSize',12,'Interpreter','latex')
ylabel('time (s)','FontSize',12,'Interpreter','latex')
%myTitle = ['Trajectory of leaf pair ' num2str(rowi) ' for $T=' num2str(tGrid(nt)) '$ s'];
%title(myTitle,'FontSize',12,'Interpreter','latex')
yticks(1:nt)
yticklabels(round(tGrid,2))
if leafType == 1
    axis([plim(1)-g plim(2)+g 0.5 nt+0.5]);
else
    axis([plim(1)-1 plim(2)+1 0.5 nt+0.5]);
end

% Colorbar
if max(d) > min(d) % no constant dose rate
    nLables = 5;
    cTicks = 0 : ceil(dmax / nLables) : dmax;
    h = colorbar('Ticks',cTicks);
    caxis(clims);
    ylabel(h, 'Dose rate (MU/s)','FontSize',12,'Interpreter','latex')
end
end