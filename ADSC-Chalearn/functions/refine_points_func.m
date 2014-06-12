function [ pd ] = refine_points_func( pd,nimage )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
points = pd(pd(:,1)==2,:);

others = pd(pd(:,1)~=2 & pd(:,1)~=3,:);
claps = pd(pd(:,1)==3,:);

indi_points = zeros(1,nimage);
indi_others = zeros(1,nimage);
for i = 1:size(points,1)
    indi_points(points(i,2):points(i,3)) = 1;
end
for i = 1:size(others,1)
    indi_others(others(i,2):others(i,3)) = 1;
end
indi_points = indi_points & (~indi_others);

indi_points(1) = 0;
indi_points(end) = 0;
indis = indi_points(2:end) - indi_points(1:end-1);
pairs = find(indis~=0);
points = [];
for i = 1:length(pairs)/2
    points = [points; 2 pairs(i*2-1) pairs(i*2)];
end

pd = [points;others;claps];
end

