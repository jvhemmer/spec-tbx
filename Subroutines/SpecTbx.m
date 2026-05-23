classdef SpecTbx
    % SpecTbx: stores colors and constants used by the SpecTbx add-on.

    properties (Constant)
        Colors = struct( ...
        'Heat', {{
            [0.1000 0.1000 0.1000]      % dark grey
            [0.0000 0.4470 0.7410]      % blue
            [0.4660 0.6740 0.1880]      % green
            [0.8290 0.6940 0.1250]      % burnt yellow
            [0.8000 0.3250 0.0980]      % orange-brown
            [0.9000 0.0000 0.0000]      % strong red
        }}, ...
        'Basic', {{
            [0.0000 0.4470 0.7410]      % blue
            [0.8500 0.3250 0.0980]      % orange
            [0.4660 0.6740 0.1880]      % green
            [0.1000 0.1000 0.1000]      % very dark grey
            [0.9290 0.6940 0.1250]      % burnt yellow
        }}, ...
        'IsothermalBlues', {{
            [0.1000 0.1000 0.1000]      % dark grey
            [0.0000 0.2235 0.5500]      % dark blue
            [0.0000 0.4470 0.7410]      % blue
            [0.3000 0.6500 0.9200]      % light blue
            [0.5000 0.8500 0.9900]      % lighter blue
        }}, ...
        'NonIsothermalColors', {{
            [0.1000 0.1000 0.1000]      % dark grey
            % [0.0000 0.4470 0.7410]      % blue
            [0.4660 0.6740 0.1880]      % green
            [0.8290 0.6940 0.1250]      % burnt yellow
            [0.8000 0.3250 0.0980]      % orange-brown
            [0.9000 0.0000 0.0000]      % strong red
        }}); 
    end
end