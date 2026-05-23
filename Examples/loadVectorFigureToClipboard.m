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

figPath = {
"C:\Users\jhemmer\Box\Johann Hemmer Data\Plasmon-induced migration (Amin 3rd project)\COMSOL\09 Sep\09192025\E-field away from surface wl=473_Analysis\figure_1.fig"
};

fig = openfig(figPath{1}, 'invisible');
print(fig, '-clipboard', '-dmeta', '-vector')
disp('Done.')