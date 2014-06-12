function [ crouch ] = Traj2Crouch( d)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
crouch = [];

framenum = max(d(:,1)) + 1;

lens = d(:,6);
trjfea = d(:,232:261);
% scols = trjfea(:,1:2:size(trjfea,2));
dcols = trjfea(:,2:2:size(trjfea,2));
dlen = sum(dcols,2);
% length(dlen)

% crouch down:
choseind=lens>50 & (dlen)>0.8;
FID = d(choseind,1);

h = histc(FID,1 : framenum);
indis = find(h>30);
startframe = indis(1)-3;
% plot( 1 : framenum,h);

% stand up:
choseind=lens>50 & (dlen)<-0.8;
FID = d(choseind,1);
h = histc(FID,1 : framenum);
indis = find(h>30);
endframe = indis(1) -1;

if endframe>startframe
    crouch = [4 startframe endframe];
end
end

