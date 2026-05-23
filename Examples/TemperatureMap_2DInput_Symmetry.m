clear
close all

expName = 'Temperature Map Bottom 35C full';

dataPath = {
"C:\Users\jhemmer\OneDrive - University of Louisville\0. Lab\4. Projects\Amin 2nd Paper\New simulations\Horizontal Plate\T=35 h=0 r=1.txt"
};

% Parameters
xRange = [0 22];
yRange = [0 25];

surfPos = [0 0]; % position of the electrode surface from origin

xTicks = [];
yTicks = [];
cTicks = [25 27 29 31 33 35];

xLabel = '{\itr} (mm)';
yLabel = '{\itz} (mm)';
cLabel = '{\itT} (°C)'; % Colorbar label

% Read data
data = readmatrix(dataPath{1});
x = data(:,1);
y = data(:,2);
T = data(:,7);   % Velocity magnitude

% Display data range
disp(append('Full range x: ', num2str(min(x)), ' to ', num2str(max(x))))
disp(append('Full range y: ', num2str(min(y)), ' to ', num2str(max(y))))

% Interpolate velocity magnitude for background heatmap
u_lin = linspace(xRange(1), xRange(2), 1000);
v_lin = linspace(yRange(1), yRange(2), 1000);
[U, V] = meshgrid(u_lin, v_lin);
Fmag = scatteredInterpolant(x, y, T, 'linear', 'none');
TemperatureGrid = Fmag(U, V);

% Plot
fig = figure(Theme='light', Units='inches');

imagesc(u_lin, v_lin, TemperatureGrid);
hold on
imagesc(-u_lin, v_lin, TemperatureGrid); % Activate this to make the x-axis symmetric about the z axis
hold off

ax = gca;
ax.XLim = [-max(xRange) max(xRange)]; % For symmetric x-axis
% ax.XLim = [0 max(xRange)];
ax.YLim = yRange;

if ~isempty(xTicks), ax.XTick = xTicks; end
if ~isempty(yTicks), ax.YTick = yTicks; end

colormap("hot")
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
c.Ticks = cTicks;
c.Limits = [min(cTicks) max(cTicks)];

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
