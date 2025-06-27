clear
close all

expName = 'Velocity Map L-shape 35C zoom (v2)';

dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\Data\New simulations\L-shaped\Velocity Map.txt"
};

% Parameters
xRange = [1 11];
yRange = [8 18];

surfPos = [4 8]; % position of the electrode surface from origin

xTicks = [2 4 6 8 10];
yTicks = [8 10 12 14 16 18];

Nq = [10 10];  % number of arrows per direction

scaling_factor = 1.2;  % arrow linear scaling factor
bias = 0.5; % arrow logarithmic scaling factor (more bias = smaller arrows)

% Reading data
data = readmatrix(dataPath{1});

x = data(:,1);
y = data(:,2);
z = data(:,3);
u = data(:,4);  % Velocity magnitude
ux = data(:,5);
uy = data(:,6);
uz = data(:,7);

% Define slicing plane: point and two directions
p0 = [0, 0, 0];          % Origin on the plane
v1 = [0, 1, 0];          % First axis on plane
v2 = [0, 0, 1];          % Second axis on plane

% Normalize vectors
v1 = v1 / norm(v1);
v2 = v2 / norm(v2);

% Create meshgrid on the plane
u_lin = linspace(xRange(1), xRange(2), 1000);  % along v1
v_lin = linspace(yRange(1), yRange(2), 1000);  % along v2
[U, V] = meshgrid(u_lin, v_lin);

% Compute 3D coordinates on the slicing plane
X3D = p0(1) + U * v1(1) + V * v2(1);
Y3D = p0(2) + U * v1(2) + V * v2(2);
Z3D = p0(3) + U * v1(3) + V * v2(3);

% Interpolate velocity magnitude
F = scatteredInterpolant(x, y, z, u, 'linear', 'none');
VelocityGrid = F(X3D, Y3D, Z3D);

% --- Quiver Grid ---
uq_lin = linspace(xRange(1), xRange(2), Nq(1));
vq_lin = linspace(yRange(1), yRange(2), Nq(2));
[Uq, Vq] = meshgrid(uq_lin, vq_lin);

Xq3D = p0(1) + Uq * v1(1) + Vq * v2(1);
Yq3D = p0(2) + Uq * v1(2) + Vq * v2(2);
Zq3D = p0(3) + Uq * v1(3) + Vq * v2(3);

% Interpolate velocity vector components at quiver grid
F1 = scatteredInterpolant(x, y, z, ux, 'linear', 'none');
F2 = scatteredInterpolant(x, y, z, uy, 'linear', 'none');
F3 = scatteredInterpolant(x, y, z, uz, 'linear', 'none');

uxq = F1(Xq3D, Yq3D, Zq3D);
uyq = F2(Xq3D, Yq3D, Zq3D);
uzq = F3(Xq3D, Yq3D, Zq3D);

% Project vectors onto the slicing plane
v3_q = [uxq(:), uyq(:), uzq(:)];
v1_rep = repmat(v1, numel(uxq), 1);
v2_rep = repmat(v2, numel(uxq), 1);
v1_component = dot(v3_q, v1_rep, 2);
v2_component = dot(v3_q, v2_rep, 2);
V1q = reshape(v1_component, size(Uq));
V2q = reshape(v2_component, size(Uq));

% Scale arrows (nonlinear)
magnitude = sqrt(V1q.^2 + V2q.^2);
magnitude(magnitude == 0) = NaN;
unit_V1 = V1q ./ magnitude;
unit_V2 = V2q ./ magnitude;
arrow_length = scaling_factor * log10(magnitude + 1).^bias;
V1q_scaled = unit_V1 .* arrow_length;
V2q_scaled = unit_V2 .* arrow_length;

% Center arrows
Uq_centered = Uq - 0.5 * V1q_scaled;
Vq_centered = Vq - 0.5 * V2q_scaled;
mask = ~isnan(V1q_scaled) & ~isnan(V2q_scaled);

% Potting
fig = figure(Theme='light', Units='inches');

im = imagesc(u_lin, v_lin, VelocityGrid);

hold on
q = quiver(Uq(mask), Vq(mask), V1q_scaled(mask), V2q_scaled(mask), ...
       0, 'w', 'LineWidth', 1.5);
hold off

ax = gca;

ax.XLim = xRange;
ax.YLim = yRange;

ax.XTick = xTicks;
ax.YTick = yTicks;

colormap("jet")
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