function [ o ] = trytracking_compare_funcg(a,b)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% re = 0;
area_a = (a(3)-a(1)+1) * (a(4)-a(2)+1);
area_b = (b(3)-b(1)+1) * (b(4)-b(2)+1);
xx1 = max(a(1), b(1));
yy1 = max(a(2), b(2));
xx2 = min(a(3), b(3));
yy2 = min(a(4), b(4));
w = xx2-xx1+1;
h = yy2-yy1+1;
o = 0;
if w > 0 && h > 0
    % compute overlap 
    o = w * h / min(area_a,area_b);
%     if o > overlap
%       re=1;
%     end
end

end

