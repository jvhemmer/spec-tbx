function [ESplit, iSplit] = splitCVToSegments(potential, current, scanRate, Elow, Ehigh)
% splitCVToSegments   Split a CV into each sweep, then window each one
%
% [ESplit, iSplit] = splitCVToSegments(potential, current, scanRate, Elow, Ehigh)
%
% Inputs:
%   potential – n×1 vector of E (V)
%   current   – n×1 vector of I (A)
%   scanRate  – scalar (V/s), only needed if you want time later
%   Elow      – lower potential cutoff (V)
%   Ehigh     – upper potential cutoff (V)
%
% Outputs:
%   ESplit – cell array, each cell is the E vector for one sweep
%   iSplit – cell array, each cell is the I vector for the same sweep

    n = numel(potential);

    % compute scan direction (+1 up, -1 down), carry forward thru any flat steps
    dE = diff(potential);
    s = sign(dE);
    for ii = 1:numel(s)
        if s(ii)==0
            if ii>1
                s(ii) = s(ii-1);
            else
                s(ii) = +1;  % assume starting forward if first step is flat
            end
        end
    end

    % find where direction flips
    turnIdx = find(diff(s)~=0)+1;  
    boundaries = [1; turnIdx; n];  % include start and end

    ESplit = {};
    iSplit = {};
    segCount = 0;

    for k = 1:numel(boundaries)-1
        idx = boundaries(k):boundaries(k+1);
        Eseg = potential(idx);
        Iseg = current(idx);

        % now apply your window if you still only want Elow–Ehigh
        inW = (Eseg >= Elow) & (Eseg <= Ehigh);
        if any(inW)
            segCount = segCount + 1;
            ESplit{segCount} = Eseg(inW);
            iSplit{segCount} = Iseg(inW);
            % if you need time you could also do:
            %   t = (Eseg(inW) - Eseg(find(inW,1))) / scanRate;
            % and stick it in a third cell array
        end
    end

    % make sure they're column cell‑arrays
    ESplit = ESplit(:);
    iSplit = iSplit(:);
end
