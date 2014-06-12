function [ fights ] = Fightdetection_func( tracks,d,nimage,walks,runs )
%UNTITLED14 Summary of this function goes here
%   d is trajectory variable
candidates_track = [];
for i = 1:length(tracks)-1
    for j = i+1:length(tracks)
        tracka = tracks{i};
        trackb = tracks{j};
        
        starta = tracka(1,5);
        enda = tracka(end,5);
        startb = trackb(1,5);
        endb = trackb(end,5);
        
        startm = max(starta,startb);
        endm = min(enda,endb);
        
        if endm>startm%overlap in time
            overlapa = tracka( find(tracka(:,5) == startm) : find(tracka(:,5) == endm),:);
            overlapb = trackb( find(trackb(:,5) == startm) : find(trackb(:,5) == endm),:);
            dis = abs((overlapa(:,1)+overlapa(:,3))/2 - (overlapb(:,1)+overlapb(:,3))/2);
            dis = medfilt1(dis);
            
            indivec = dis<100 & dis>30;
            
            dis_change = abs(dis(2:end)-dis(1:end-1));
            indivec(1:end-1) = indivec(1:end-1) & dis_change<10;
            candidates_track = [candidates_track; overlapa(indivec,:) overlapb(indivec,:)];
        end
    end
end

walks_runs = [walks;runs];
for i = 1:size(walks_runs,1)
    indis = candidates_track(:,end)>=walks_runs(i,2) & candidates_track(:,end)<=walks_runs(i,3);
    candidates_track(indis,:) = [];
end


lens = d(:,6);
choseind=lens>50;% & lens<100;
ds = d(choseind,:);

trjfea = ds(:,232:261);
dcols = trjfea(:,1:2:size(trjfea,2));
dlen = sum(dcols,2);
abdlen = sum(abs(dcols),2);
choseind1=abs(dlen)<0.2 & abdlen>0.6;
% ds = ds(choseind,:);
% 2
trjfea = ds(:,232:261);
dcols = trjfea(:,2:2:size(trjfea,2));
dlen = sum(dcols,2);
abdlen = sum(abs(dcols),2);
choseind2=abs(dlen)<0.2 & abdlen>0.6;
ds = ds(choseind1|choseind2,:);
FID = ds(:,1);

len = nimage;
h = histc(FID,1 : len);
h = medfilt1(h,5);

indis = (h>35);
candidates_frameids = candidates_track(:,end);
final_frameid_indis = indis(candidates_frameids);
final_frameid = candidates_frameids(final_frameid_indis==1);

frameindi = zeros(1,len);
frameindi(final_frameid) = 1;

frameindi = medfilt1(frameindi,5);
frameindi(1) = 0;
frameindi(end) = 0;
indis = frameindi(2:end) - frameindi(1:end-1);
pairs = find(indis~=0);
fights = [];
for i = 1:length(pairs)/2
    fights = [fights; 11 pairs(i*2-1) pairs(i*2)];
end

lens = fights(:,3)-fights(:,2);
fights(lens<6,:) = [];

fights(:,2) = fights(:,2)-25;
fights(:,3) = fights(:,3)+5;

end

