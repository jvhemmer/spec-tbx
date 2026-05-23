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

% Read data
data = readmatrix(dataPath{1});
x = data(:,1);
y = data(:,2);
z = data(:,3);
T = data(:,8);

% Define slicing plane
p0 = [0, 0, 0];          % Origin on the plane
v1 = [0, 1, 0];          % First axis on plane
v2 = [0, 0, 1];          % Second axis on plane

% Normalize basis vectors
v1 = v1 / norm(v1);
v2 = v2 / norm(v2);

% 2D grid coordinates (u, v) over the plane
u_lin = linspace(xRange(1), xRange(2), 5000);
v_lin = linspace(yRange(1), yRange(2), 5000);
[U, V] = meshgrid(u_lin, v_lin);

% Compute 3D positions on the slice: X = p0 + u*v1 + v*v2
X3D = p0(1) + U * v1(1) + V * v2(1);
Y3D = p0(2) + U * v1(2) + V * v2(2);
Z3D = p0(3) + U * v1(3) + V * v2(3);

% Interpolate temperature on the defined 3D surface
F = scatteredInterpolant(x, y, z, T, 'linear', 'none');
T_slice = F(X3D, Y3D, Z3D);

% Plotting
fig = figure(Theme='light', Units='inches');
im = imagesc(u_lin, v_lin, T_slice);
set(gca, 'YDir', 'normal');

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

c.Label.String = '{\itT} (°C)';
c.Units = 'inches';
c.FontName = 'Arial';
c.FontSize = 18;
c.Label.FontName = 'Arial';
c.Label.FontSize = 20;
c.LineWidth = 1.5;
c.Ticks = cTicks;
c.Limits = [min(cTicks) max(cTicks)];
clim(c.Limits)

set(ax, FontSize=18, LineWidth=1.5, Units='inches', Box='on', Layer='top')

grid off

% Adjust size
PlotWidth = 5;
AspectRatio = 1.2;
PlotHeight = PlotWidth / AspectRatio;

ax.Position([3 4]) = [PlotWidth PlotHeight];
fig.Position([3 4]) = ax.OuterPosition([3 4]);
ax.OuterPosition(1) = ax.OuterPosition(1) + ax.TickLength(1);
fig.Position(3) = fig.Position(3) + c.Label.Extent(3);

% Save analysis
savePath = createAnalysisFolder(dataPath{1}, expName);
saveAllFigs(savePath, 'fig', 'png', 'pdf');
saveReport(savePath);
copyFile(savePath, dataPath);
