function [ score ] = cal_ratio_TrajBox( frameid, Trj, tracks )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
score = 0;

xs = Trj(:,1:2:size(Trj,2));
ys = Trj(:,2:2:size(Trj,2));
xs = xs(:);
ys = ys(:);

for i = 1:length(tracks)
    indi = find(tracks{i}(:,5) == frameid);
    if ~isempty(indi)
        x1 = tracks{i}(indi,1)*2;
        y1 = tracks{i}(indi,2)*2;
        x2 = tracks{i}(indi,3)*2;
        y2 = tracks{i}(indi,4)*2;
        xs_in = xs(xs>x1 & xs<x2 & ys>y1 & ys<y2);
        ys_in = ys(xs>x1 & xs<x2 & ys>y1 & ys<y2);
        if ~isempty(xs_in)
            overlap = (max(xs_in) - min(xs_in))*(max(ys_in) - min(ys_in))/((x2-x1)*(y2-y1));
            if length(xs_in)/(16) > 10
                score = max(score,overlap);
            end
        end
    end
end

end

