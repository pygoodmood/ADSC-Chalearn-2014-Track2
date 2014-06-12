function [ jump ] = TrajTrack2Jump( d, tracks )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
jump = [];

framenum = max(d(:,1)) + 1;

lens = d(:,6);
trjfea = d(:,232:261);
dcols = trjfea(:,2:2:size(trjfea,2));
dlen = sum(dcols,2);
abdlen = sum(abs(dcols),2);

choseind=lens>100 & abs(dlen)<0.2 & abdlen>0.8;

FID = d(choseind,1);
h = histc(FID,1 : framenum);
indis = find(h>20);

del = [];
TRJ = d(choseind,8:39);
for i = 1:length(indis)
    Trj = TRJ(FID==indis(i),:);% Trj in current frame
    [ score ] = cal_ratio_TrajBox(indis(i), Trj, tracks );
    if score<0.6
        del = [del i];
    end
end

indis(del) = [];


frameindi = zeros(1,framenum);
frameindi(indis) = 1;

frameindi = medfilt1(frameindi);
frameindi(1) = 0;
frameindi(end) = 0;
pairindis = frameindi(2:end) - frameindi(1:end-1);
pairs = find(pairindis~=0);
jump = [];
for i = 1:length(pairs)/2
    jump = [jump; 5 pairs(i*2-1)-8 pairs(i*2)];
end

% jump = [5 indis(1)-8 indis(1)+1];


end

