clear
close all

expName = 'Velocity Map Horizontal Plate 35C';

dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\New simulations\Horizontal Plate\T=35 h=0 r=1.txt"
};

% Parameters
xRange = [0 22];
yRange = [0 25];

surfPos = [0 0]; % position of the electrode surface from origin

xTicks = [];
yTicks = [];

Nq = [20 15];       % Number of arrows per direction
scaling_factor = 2;
bias = 0.7;

xLabel = '{\itr} (mm)';
yLabel = '{\itz} (mm)';
cLabel = '{\itu} (mm/s)'; % Colorbar label

% Read data
data = readmatrix(dataPath{1});
x = data(:,1);
y = data(:,2);
u = data(:,3);   % Velocity magnitude
ux = data(:,4);  % X component
uy = data(:,5);  % Y component
uz = data(:,6);  % Z component

% Display data range
disp(append('Full range x: ', num2str(min(x)), ' to ', num2str(max(x))))
disp(append('Full range y: ', num2str(min(y)), ' to ', num2str(max(y))))

% Interpolate velocity magnitude for background heatmap
u_lin = linspace(xRange(1), xRange(2), 1000);
v_lin = linspace(yRange(1), yRange(2), 1000);
[U, V] = meshgrid(u_lin, v_lin);
Fmag = scatteredInterpolant(x, y, u, 'linear', 'none');
VelocityGrid = Fmag(U, V);

% Generate grid for quiver arrows
uq_lin = linspace(xRange(1), xRange(2), Nq(1));
vq_lin = linspace(yRange(1), yRange(2), Nq(2));
[Uq, Vq] = meshgrid(uq_lin, vq_lin);

F1 = scatteredInterpolant(x, y, ux, 'linear', 'none');
F2 = scatteredInterpolant(x, y, uz, 'linear', 'none');
V1q = F1(Uq, Vq);
V2q = F2(Uq, Vq);

% Apply nonlinear scaling
magnitude = sqrt(V1q.^2 + V2q.^2);
magnitude(magnitude == 0) = NaN;
unit_V1 = V1q ./ magnitude;
unit_V2 = V2q ./ magnitude;

scale = scaling_factor * log10(magnitude + 1).^bias;
V1q_scaled = unit_V1 .* scale;
V2q_scaled = unit_V2 .* scale;

% Center arrows on grid
Uq_centered = Uq - 0.5 * V1q_scaled;
Vq_centered = Vq - 0.5 * V2q_scaled;
mask = ~isnan(V1q_scaled) & ~isnan(V2q_scaled);

% Plot
fig = figure(Theme='light', Units='inches');
imagesc(u_lin, v_lin, VelocityGrid);
hold on
quiver(Uq_centered(mask), Vq_centered(mask), ...
       V1q_scaled(mask), V2q_scaled(mask), ...
       0, 'w', 'LineWidth', 1.5);
hold off

ax = gca;
ax.XLim = xRange;
ax.YLim = yRange;

if ~isempty(xTicks), ax.XTick = xTicks; end
if ~isempty(yTicks), ax.YTick = yTicks; end

colormap("jet")
c = colorbar;

xlabel(xLabel, FontSize=20, FontName='Arial');
ylabel(yLabel, FontSize=20, FontName='Arial');

% ax.XTickLabel = ax.XTick - surfPos(1);
% ax.YTickLabel = ax.YTick - surfPos(2);

c.Label.String = cLabel;
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
PlotHeight = PlotWidth / AspectRatio;
ax.Position([3 4]) = [PlotWidth PlotHeight];
fig.Position([3 4]) = ax.OuterPosition([3 4]);
ax.OuterPosition(1) = ax.OuterPosition(1) + ax.TickLength(1);
fig.Position(3) = fig.Position(3) + c.Label.Extent(3);

% Save everything
savePath = createAnalysisFolder(dataPath{1}, expName);
saveAllFigs(savePath, 'fig', 'png', 'pdf')
saveReport(savePath)
copyFile(savePath, dataPath)
