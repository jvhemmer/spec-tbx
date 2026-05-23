% Plot E-field or Enhancement from COMSOL simulated data. Input must be
% 2D data.
%
%   THE WILSON LAB
%   
%   Created by: Johann Hemmer
%   johann.hemmer@louisville.edu
%   18 Sep 2025
clear
close all

%% Parameters

% Path to data
expName = 'E-field away from surface, x-axis fixed';

dataPath = "C:\Users\jhemmer\Box\Johann Hemmer Data\Plasmon-induced migration (Amin 3rd project)\COMSOL\09 Sep\09222025\Efield away from surface x-axis fixed wl=473.txt";

wl = 473;
r0 = -100; % particle radius, nm

% E0 = 2195.9; % For 0.64 W/cm^2
% E0 = 2689.5; % For 0.96 W/cm^2
% E0 = 3093.4; % For 1.27 W/cm^2
% E0 = 3461.2; % For 1.59 W/cm^2
% E0 = 4234.7; % For 2.38 W/cm^2

% Plotting parameters
AspectRatio = 1.2;
% xRange = [-200 200];
% yRange = [-200 200]/AspectRatio;
overwriteFile = true;

surfPos = [0 0];

xTicks = [];
yTicks = [];
% cTicks = [25 27 29 31 33 35];

xLabel = '{\itz} (nm)';
yLabel = '{\itI}_0 (W/cm^2)';
zLabel = '|{\bfE}| (kV/m)';

%% Process
data = readmatrix(dataPath{1});
z = -(data(:,1) - r0);
I0 = [0.64 0.96 1.27 1.59 2.38];
E = [data(:,4) data(:,5) data(:,6) data(:,7) data(:,8)]';

[U, V] = meshgrid(z, I0);

% Convert E-field to enhancement
% E = (E./E0).^2;

%% Plot
fig = figure(Theme='light', Units='inches');

% Make 3D plot
s = surf(U, V, E./1e3);

ax = gca;
% ax.XLim = xRange;
% ax.YLim = yRange;

if ~isempty(xTicks), ax.XTick = xTicks; end
if ~isempty(yTicks), ax.YTick = yTicks; end

colormap("nebula")
% c = colorbar;

xlabel(xLabel, FontSize=20, FontName='Arial');
ylabel(yLabel, FontSize=20, FontName='Arial');
zlabel(zLabel, FontSize=20, FontName='Arial');

zlim([0 55])

% ax.XTickLabel = ax.XTick - surfPos(1);
% ax.YTickLabel = ax.YTick - surfPos(2);

% c.Label.String = cLabel;
% c.Units = 'inches';
% c.FontName = 'Arial';
% c.FontSize = 18;
% c.Label.FontName = 'Arial';
% c.Label.FontSize = 20;
% c.LineWidth = 2;
% clim([1 140]);

set(ax, FontSize=18, LineWidth=2, Units='inches', Box='on', Layer='top', YDir='normal')
grid off

view(45, 30)

% Adjust size
PlotWidth = 5;
PlotHeight = PlotWidth / AspectRatio;
ax.Position([3 4]) = [PlotWidth PlotHeight];
fig.Position([3 4]) = ax.OuterPosition([3 4]);
ax.OuterPosition(1) = ax.OuterPosition(1) + ax.TickLength(1);
% fig.Position(3) = fig.Position(3) + c.Label.Extent(3);

% annotation(fig,'textbox',...
%     [0.184476581952313 0.160600445087139 0.252544024249423 0.141405561159923],...
%     'VerticalAlignment','cap',...
%     'String',{append('{\it\lambda} = ',num2str(wl,3),' nm')},...
%     'LineWidth',2,...
%     'FontSize',18,...
%     'FitBoxToText','off',...
%     'BackgroundColor',[1 1 1]);

expName = append(expName, ' wl=', num2str(wl,3));

%% Save
savePath = createAnalysisFolder(dataPath{1}, expName, 'Overwrite', overwriteFile);
saveAllFigs(savePath, 'fig', 'png', 'pdf')
saveReport(savePath)
copyFile(savePath, dataPath)
