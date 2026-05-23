clear
close all

expName = 'Temperature Map L-shape 35C yz-plane zoom (v2)';

dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Data\New simulations\L-shaped\Velocity Map.txt"
};

% Parameters
xRange = [1 11];
yRange = [2 18];

surfPos = [4 8]; % position of the electrode surface from origin

xTicks = [2 4 6 8 10];
yTicks = [2 4 6 8 10 12 14 16 18];
cTicks = [25 27 29 31 33 35];

% Reading data
data = readmatrix(dataPath{1});

x = data(:,1);
y = data(:,2);
z = data(:,3);
T = data(:,8);

% Define slicing plane
p0 = [0, 0, 0];          % Origin on the plane
v1 = [0, 1, 0];          % First axis on plane
v2 = [0, 0, 1];          % Second axis on plane

% ---- Slice the Plane ----
v1 = v1 / norm(v1);
v2 = v2 / norm(v2);
normal = cross(v1, v2);

points = [x, y, z];
rel_pts = points - p0;

dist_to_plane = abs(rel_pts * normal');
tol = 1e-3;  % adjust if needed

plane_idx = dist_to_plane < tol;

% ---- Project onto 2D plane ----
u_coords = rel_pts(plane_idx,:) * v1';
v_coords = rel_pts(plane_idx,:) * v2';
T_vals = T(plane_idx);

% Plot range
disp(append('Full range x: ', num2str(min(u_coords)), ' to ', num2str(max(u_coords))))
disp(append('Full range y: ', num2str(min(v_coords)), ' to ', num2str(max(v_coords))))

u_lin = linspace(xRange(1), xRange(2), 1000);
v_lin = linspace(yRange(1), yRange(2), 1000);

[U, V] = meshgrid(u_lin, v_lin);

F = scatteredInterpolant(u_coords, v_coords, T_vals, 'linear', 'none');
VelocityGrid = F(U, V);

% Potting
fig = figure(Theme='light', Units='inches');

im = imagesc(u_lin, v_lin, VelocityGrid);

ax = gca;

ax.XLim = xRange;
ax.YLim = yRange;

if ~isempty(xTicks), ax.XTick = xTicks; end
if ~isempty(yTicks), ax.YTick = yTicks; end

colormap("hot")
c = colorbar;

xlabel('{\ity} (mm)', FontSize=20, FontName='Arial');
ylabel('{\itz} (mm)', FontSize=20, FontName='Arial');

ax.XTickLabel = ax.XTick - surfPos(1);
ax.YTickLabel = ax.YTick - surfPos(2);

c.Label.String = '{\itu} (mm/s)';
c.Units = 'inches';
c.FontName = 'Arial';
c.FontSize = 18;
c.Label.FontName = 'Arial';
c.Label.FontSize = 20;
c.LineWidth = 1.5;
c.Ticks = cTicks;
c.Limits = [min(cTicks) max(cTicks)];

set(ax, FontSize=18, LineWidth=1.5, Units='inches', Box='on', Layer='top', YDir='normal')

grid off

% Adjust size
PlotWidth = 5;
AspectRatio = 1.2;

PlotHeight = PlotWidth/AspectRatio;
ax.Position([3 4]) = [PlotWidth PlotHeight];
fig.Position([3 4]) = ax.OuterPosition([3 4]);
ax.OuterPosition(1) = ax.OuterPosition(1) + ax.TickLength(1);

fig.Position(3) = fig.Position(3) + c.Label.Extent(3);

% Creating folder to save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);

% Saving figures
saveAllFigs(savePath, 'fig', 'png', 'pdf')

% Saving report
saveReport(savePath)

% Copy files
copyFile(savePath, dataPath)