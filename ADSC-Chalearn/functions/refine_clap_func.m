function [ claps_refined ] = refine_clap_func( d,track,claps,nimage )
%UNTITLED20 Summary of this function goes here
%   Detailed explanation goes here
len = size(track,1);
counts = zeros(2,len);

FID = d(:,1);
TRJ = d(:,8:39);
TRJ_len = d(:,6);

for i = 1:len
    frameid = track(i,5);
    left = track(i,1)*2;
    right = track(i,3)*2;
    up = track(i,2)*2;
    down = track(i,4)*2;
%     width14 = (right - left + 1 )/4;
%     x1 = left - width14;
%     x2 = left + width14;
%     x3 = right - width14;
%     x4 = right + width14;
    hight1_065 = (down - up + 1 )*0.065;
    hight2_375 = (down - up + 1 )*0.375;
%     y1 = up - hight17;
%     y2 = up + 2*hight17;
%     y3 = down - 2*hight17;
%     y4 = down + hight17;
    
    indexs = find(FID == frameid);
    for j = 1:length(indexs)
        lentrj = TRJ_len(indexs(j))/10;
        x = TRJ(indexs(j),1:2:29);
        y = TRJ(indexs(j),2:2:30);
        indiy = ceil((y-up-hight1_065)/(hight2_375-hight1_065+1));
        indiy = (indiy == 1)+1;
        
        for k = 1:15
            xi = x(k);
            yi = y(k);
            if xi>left && xi<right && yi>up && yi<down
                counts(indiy(k),i) = counts(indiy(k),i)+1*lentrj;
            end
        end
    end
end
sumofcounts = sum(counts)+1;
counts = counts./repmat(sumofcounts,[2 1]);
indi = find(counts(2,:)>0.5);

frameids = track(indi,5);

% claps 
indis1 = zeros(1,nimage);
indis2 = zeros(1,nimage);

indis1(frameids) = 1;
for i = 1:size(claps,1)
    indis2(claps(i,2):claps(i,3)) = 1;
end

frameindi = indis1 & indis2;
% frameindi = medfilt1(frameindi,5);

frameindi(1) = 0;
frameindi(end) = 0;
indis = frameindi(2:end) - frameindi(1:end-1);
pairs = find(indis~=0);

if length(pairs)>2
    del = [];
    for i = 1:(length(pairs)-2)/2
        if pairs(i*2+1)-pairs(i*2) < 10
            del = [del i*2 i*2+1];
        end
    end
    pairs(del) = [];
end

claps_refined = [];
for i = 1:length(pairs)/2
    claps_refined = [claps_refined; 3 pairs(i*2-1) pairs(i*2)];
end
if ~isempty(claps_refined)
    lens = claps_refined(:,3)-claps_refined(:,2);
    claps_refined(lens<7,:) = [];

    claps_refined(:,2) = max(1,claps_refined(:,2) -7);
end
end

