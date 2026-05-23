clear
close all

expName = 'Temperature Map L-shape 35C xz-plane zoom symmetry';

dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\New simulations\L-shaped\Velocity Map.txt"
};

% Parameters
xRange = [0 8];
yRange = [4 20];

surfPos = [0 8]; % position of the electrode surface from origin

xTicks = [-8 -6 -4 -2 0 2 4 6 8];
yTicks = [0 4 8 12 16 20];
cTicks = [25 27 29 31 33 35];

% Read data
data = readmatrix(dataPath{1});
x = data(:,1);
y = data(:,2);
z = data(:,3);
T = data(:,8);

% Define slicing plane
p0 = [0, 4, 0];  % a point on the plane
v1 = [1, 0, 0];    % x-direction
v2 = [0, 0, 1];    % z-direction

% Normalize basis vectors
v1 = v1 / norm(v1);
v2 = v2 / norm(v2);

% 2D grid coordinates (u, v) over the plane
u_lin = linspace(xRange(1), xRange(2), 1000);
v_lin = linspace(yRange(1), yRange(2), 1000);
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

hold on
imagesc(-u_lin, v_lin, T_slice);
hold off

set(gca, 'YDir', 'normal');

ax = gca;
ax.XLim = [-max(xRange) max(xRange)];
ax.YLim = yRange;

if ~isempty(xTicks), ax.XTick = xTicks; end
if ~isempty(yTicks), ax.YTick = yTicks; end

colormap("hot")
c = colorbar;

xlabel('{\itx} (mm)', FontSize=20, FontName='Arial');
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
