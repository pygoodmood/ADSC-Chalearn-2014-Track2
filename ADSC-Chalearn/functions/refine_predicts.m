function [ pd ] = refine_predicts( pd,counts,coords_of_two )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
%% counts
%% 9 Hug 10 Kiss
d = [];
for i = 1 : size(coords_of_two,1)/2
    right = max( coords_of_two(i*2-1,2) , coords_of_two(i*2,2) );
    left = min( coords_of_two(i*2-1,4) , coords_of_two(i*2,4) );
    d = [d; coords_of_two(i*2-1,1) right-left ];
end

d(:,2) = medfilt1(d(:,2));
d(:,2) = d(:,2)<5;

d_back = d;

indivec = zeros(1,size(counts,2));
d = d(d(:,2) == 1,:);
indivec(d(:,1)) = 1;

indis = find((indivec(2:end) - indivec(1:end-1)) ~= 0);
Hug_kiss = [];
for i = 1:length(indis)/2
    Hug_kiss = [Hug_kiss;indis(i*2-1) indis(i*2)];
end

% pd(find(pd(:,1) == 9),:) = [];
% pd(find(pd(:,1) == 10),:) = [];
% pd = [pd;ones(size(Hug_kiss),1)*9 Hug_kiss];
% pd = [pd;ones(size(Hug_kiss),1)*10 Hug_kiss];

% dd = zeros(1,max(coords_of_two(:,1)));
% for i = 1:size(d,1)
%     dd(d(i,1)) = d(i,2);
% end
% plot(1:length(dd),dd)

indivec = zeros(1,size(counts,2));
d = d_back(d_back(:,2) == 0,:);
indivec(d(:,1)) = 1;
%% shake hands
% results should contain keypose of shake hands
c = counts(1,:);

c = c&indivec;

indis = find(pd(:,1) == 8);
del = [];
for j = 1:length(indis)
    if sum( c(pd(indis(j),2):pd(indis(j),3)) ) == 0
        del = [del indis(j)];
    end
end
pd(del,:) = [];

%% two person activeties :  11 Fight 
% actions should contain 2 persons' detection results
% c = (counts(2,:) == 2);
c = indivec;
for ci = 11
    indis = find(pd(:,1) == ci);
    indi_vector = zeros(1,size(counts,2));
    for i = 1:size(indis,1)
        indi_vector( pd(indis(i),2):pd(indis(i),3) ) = 1;
    end
    overlap_vector = indi_vector & c;
    
    pd(indis,:) = [];
    
    indis = find((overlap_vector(2:end) - overlap_vector(1:end-1)) ~= 0);
    for i = 1:length(indis)/2
        pd = [pd;ci indis(i*2-1) indis(i*2)];
    end
end

end

