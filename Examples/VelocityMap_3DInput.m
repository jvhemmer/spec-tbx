clear
close all

expName = 'Velocity Map Horizontal 35C zoom';

dataPath = {
    "C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\New simulations\L-shaped\Velocity Map.txt";
};

% Parameters
xRange = [1 11];
yRange = [8 18];

surfPos = [4 8]; % position of the electrode surface from origin

xTicks = [2 4 6 8 10];
yTicks = [8 10 12 14 16 18];

Nq = [15 15];  % number of arrows per direction

scaling_factor = 0.8;  % arrow linear scaling factor
bias = 0.7; % arrow logarithmic scaling factor

% Reading data
data = readmatrix(dataPath{1});

x = data(:,1);
y = data(:,2);
z = data(:,3);
u = data(:,4);  % Velocity magnitude
ux = data(:,5);
uy = data(:,6);
uz = data(:,7);

% Define slicing plane
p0 = [0, 0, 0];         % Origin of the slicing plane
v1 = [0, 1, 0];         % First in-plane direction vector
v2 = [0, 0, 1];         % Second in-plane direction vector

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
u_vals = u(plane_idx);

ux_plane = ux(plane_idx);
uy_plane = uy(plane_idx);
uz_plane = uz(plane_idx);

% Reconstruct full 3D vector at plane points
v3_plane = [ux_plane, uy_plane, uz_plane];

% Project velocity vectors onto the plane basis (v1 and v2 directions)
v1_component = dot(v3_plane, repmat(v1, size(v3_plane,1), 1), 2);
v2_component = dot(v3_plane, repmat(v2, size(v3_plane,1), 1), 2);
% ---- Interpolation and Plot ----
% u_lin = linspace(min(u_coords), max(u_coords), 1000);
% v_lin = linspace(min(v_coords), max(v_coords), 1000);

% Plot range
disp(append('Full range x: ', num2str(min(u_coords)), ' to ', num2str(max(u_coords))))
disp(append('Full range y: ', num2str(min(v_coords)), ' to ', num2str(max(v_coords))))

u_lin = linspace(xRange(1), xRange(2), 1000);
v_lin = linspace(yRange(1), yRange(2), 1000);

[U, V] = meshgrid(u_lin, v_lin);

F = scatteredInterpolant(u_coords, v_coords, u_vals, 'linear', 'none');
VelocityGrid = F(U, V);

% --- Set quiver grid resolution ---
uq_lin = linspace(xRange(1), xRange(2), Nq(1));
vq_lin = linspace(yRange(1), yRange(2), Nq(2));

% uq_lin = logspace(log10(xRange(1)+1), log10(xRange(2)+1), Nq(1))-1;
% vq_lin = logspace(log10(yRange(1)+1), log10(yRange(2)+1), Nq(2))-1;

[Uq, Vq] = meshgrid(uq_lin, vq_lin);

% Interpolate vector components onto the quiver grid
F1 = scatteredInterpolant(u_coords, v_coords, v1_component, 'linear', 'none');
F2 = scatteredInterpolant(u_coords, v_coords, v2_component, 'linear', 'none');
V1q = F1(Uq, Vq);
V2q = F2(Uq, Vq);

% Apply log scaling (optional)
magnitude = sqrt(V1q.^2 + V2q.^2);
magnitude(magnitude == 0) = NaN;  % avoid log(0)
scale = scaling_factor * log10(magnitude + 1).^bias;

V1q = V1q ./ magnitude .* scale;
V2q = V2q ./ magnitude .* scale;

% Compute centered origins
Uq = Uq - 0.5 * V1q;
Vq = Vq - 0.5 * V2q;

% Potting
fig = figure(Theme='light', Units='inches');

im = imagesc(u_lin, v_lin, VelocityGrid);

% [Xg, Yg] = meshgrid(u_lin, v_lin);
% surf(Xg, Yg, zeros(size(VelocityGrid)), VelocityGrid, ...
%      'EdgeColor', 'none');
% view(2);

hold on
mask = ~isnan(V1q) & ~isnan(V2q);
q = quiver(Uq(mask), Vq(mask), V1q(mask), V2q(mask), ...
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