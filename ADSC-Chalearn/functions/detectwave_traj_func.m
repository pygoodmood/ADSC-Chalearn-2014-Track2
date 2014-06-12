function [ waves ] = detectwave_traj_func( d,track,nimage )
%UNTITLED20 Summary of this function goes here
%   Detailed explanation goes here
len = size(track,1);
counts = zeros(9,len);

trjfea = d(:,232:261);
dxs = trjfea(:,1:2:size(trjfea,2));
ablenx = sum(abs(dxs),2);
dys = trjfea(:,2:2:size(trjfea,2));
ableny = sum(abs(dys),2);

r = ablenx./(ablenx+ableny);

choseind=r>0.5;
ds = d(choseind,:);

FID = ds(:,1);
TRJ = ds(:,8:39);
TRJ_len = ds(:,6);

for i = 1:len
    frameid = track(i,5);
    left = track(i,1)*2;
    right = track(i,3)*2;
    up = track(i,2)*2;
    down = track(i,4)*2;
    width14 = (right - left + 1 )/4;
    x1 = left - width14;
%     x2 = left + width14;
%     x3 = right - width14;
%     x4 = right + width14;
    hight17 = (down - up + 1 )/7;
    y1 = up - hight17;
%     y2 = up + 2*hight17;
%     y3 = down - 2*hight17;
%     y4 = down + hight17;
    
    indexs = find(FID == frameid);
    if length(indexs)>5
        for j = 1:length(indexs)
            lent = TRJ_len(indexs(j))/10;
            x = TRJ(indexs(j),1:2:29);
            y = TRJ(indexs(j),2:2:30);
            ai = ceil((x-x1)/(width14*2));
            bi = ceil((y-y1)/(hight17*3));
            for k = 1:15
                a = ai(k);
                b = bi(k);
                if a>0 & a<4 & b>0 & b<4
                    counts((b-1)*3+a,i) = counts((b-1)*3+a,i)+1*lent;
                end
            end
        end
    end
end
sumofcounts = sum(counts)+1;
counts = counts./repmat(sumofcounts,[9 1]);
indis = counts(3,:)>0.8;
frames = track(indis,5);
groups = [];
while ~isempty(frames)
    if isempty(groups)
        groups{1} = [frames(1)];
        frames(1) = [];
    else
        ii = 0;
        for i = 1:length(groups)
            if min(frames(1)-groups{i})<5
                groups{i} = [groups{i} frames(1)];
                ii = 1;
                break;
            end
        end
        if ii==0
            groups = [groups {frames(1)}];
        end
        frames(1) = [];
    end
end
del = [];
for i = 1:length(groups)
    if length(groups{i})<2
        del = [del i];
    end
end
groups(del) = [];

frameindi = zeros(1,nimage);
for i = 1:length(groups)
    group = groups{i};
    for j = 1:length(group)
        frameindi(max(1,group(j) - 16):max(1,group(j)))=1;
    end
end
frameindi = medfilt1(frameindi);
frameindi(1) = 0;
frameindi(end) = 0;
indis = frameindi(2:end) - frameindi(1:end-1);
pairs = find(indis~=0);
waves = [];
for i = 1:length(pairs)/2
    waves = [waves; 1 pairs(i*2-1) pairs(i*2)];
end


%left
indis = counts(1,:)>0.8;
frames = track(indis,5);
groups = [];
while ~isempty(frames)
    if isempty(groups)
        groups{1} = [frames(1)];
        frames(1) = [];
    else
        ii = 0;
        for i = 1:length(groups)
            if min(frames(1)-groups{i})<5
                groups{i} = [groups{i} frames(1)];
                ii = 1;
                break;
            end
        end
        if ii==0
            groups = [groups {frames(1)}];
        end
        frames(1) = [];
    end
end
del = [];
for i = 1:length(groups)
    if length(groups{i})<2
        del = [del i];
    end
end
groups(del) = [];

frameindi = zeros(1,nimage);
for i = 1:length(groups)
    group = groups{i};
    for j = 1:length(group)
        frameindi(max(1,group(j) - 16):max(1,group(j)))=1;
    end
end
frameindi = medfilt1(frameindi);
frameindi(1) = 0;
frameindi(end) = 0;
indis = frameindi(2:end) - frameindi(1:end-1);
pairs = find(indis~=0);
for i = 1:length(pairs)/2
    waves = [waves; 1 pairs(i*2-1) pairs(i*2)];
end

end

