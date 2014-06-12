function [ tracks ] = tracking_main_func( )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
ifdraw = 0;
outputpath=['Keypose_results\'];
list = dir([outputpath 'result_of_frame*.jpg.mat']);
tracks = [];
tracks_finished = [];
allboxes = [];
for i = 1:length(list)
    load([outputpath list(i).name]);
    allboxes{i} = plot_boxes{end};
end
fprintf('start tracking..\n');
for i = 1:length(allboxes)
%     fprintf('%dth frame on tracking..\n',i);
    
%     load([outputpath list(i).name]);
    boxes = allboxes{i};

    if ~isempty(tracks)
        indis = [];
        for j = 1:length(tracks)
            if abs(tracks{j}(end,5) - i) >3
                indis = [indis j];
            end
        end
        if ~isempty(indis)
            for j = length(indis):1
                tracks_finished = [tracks_finished tracks(indis(j))];
                tracks(indis(j)) = [];
            end
        end
    end
    if ~isempty(boxes)
        boxes(:,5) = i;
        if isempty(tracks)
            for j = 1:size(boxes,1)
                tracks = [tracks;{boxes(j,:)}];
            end
        else
            scores = zeros(length(tracks),size(boxes,1));
            for j = 1:length(tracks)
                for k = 1:size(boxes,1)
                    a = tracks{j};
                    a = a(end,:);
                    b = boxes(k,:);
                    scores(j,k) = trytracking_compare_funcg(a,b);
                end
            end
            del = [];
            while sum(scores(:))~=0
                matchedid = find(scores == max(scores(:)));
                matchedid = matchedid(1);
                [rowi,coli] = ind2sub(size(scores),matchedid);
                tracks{rowi} = [tracks{rowi};boxes(coli,:)];
                scores(rowi,:) = 0;
                scores(:,coli) = 0;
                del = [del coli];
            end
            
            del = sort(del);
            if ~isempty(del)
                for k = length(del):-1:1
                    boxes(del(k),:) = [];
                end
            end
            
            if ~isempty(boxes)
                for j = 1:size(boxes,1)
                    tracks = [tracks;{boxes(j,:)}];
                end
            end
        end
    end
end
tracks = [tracks' tracks_finished];

for i = 1:length(tracks)
    tracks{i}(:,1) = medfilt1(tracks{i}(:,1));
    tracks{i}(:,2) = medfilt1(tracks{i}(:,2));
    tracks{i}(:,3) = medfilt1(tracks{i}(:,3));
    tracks{i}(:,4) = medfilt1(tracks{i}(:,4));
end
% remove short
del = [];
for i = 1:length(tracks)
    if size(tracks{i},1) <= 3
        del = [del i];
    end
end
del = fliplr(del);
for i = 1:length(del)
    tracks(del(i)) = [];
end

% interp tracks
for i = 1:length(tracks)
    tracks{i} = targetdatainterp( tracks{i} );
end
%remove short again
del = [];
for i = 1:length(tracks)-1
    for j = i+1:length(tracks)
        tracka = tracks{i};
        trackb = tracks{j};
        
        starta = tracka(1,5);
        enda = tracka(end,5);
        startb = trackb(1,5);
        endb = trackb(end,5);
        
        if enda-starta+1 > endb-startb+1
            shorti = j;
        else
            shorti = i;
        end
        
        startm = max(starta,startb);
        endm = min(enda,endb);
        if endm > startm & endm - startm < 20 & max(enda-starta+1,endb-startb+1)>200
            if max((endm-startm+1)/(enda-starta+1),(endm-startm+1)/(endb-startb+1))==1
                overlapa = tracka( find(tracka(:,5) == startm) : find(tracka(:,5) == endm),:);
                overlapb = trackb( find(trackb(:,5) == startm) : find(trackb(:,5) == endm),:);
                dis = abs((overlapa(:,1)+overlapa(:,3))/2 - (overlapb(:,1)+overlapb(:,3))/2);
                if mean(dis)<15
                    del = [del shorti];
                end
            end
        end
    end
end
tracks(del) = [];
% draw tracks trajectory
% figure();
% for i = 1:length(tracks)
%     x = tracks{i}(:,5)';
%     y = ( tracks{i}(:,1) + tracks{i}(:,3) )/2;
%     y = y';
%     hold on;
%     
%     plot(x,y);
%     plot(x(1),y(1),'r.');
%     text(x(1),y(1),sprintf('%d.',i));
%     plot(x(end),y(end),'r.');
%     axis([0 1000 0 320]);
%     hold off;
% end

% foldername =
% ['C:\Users\Pei.Yong\Desktop\ChalearnLookingatPeople2014\UseDenseTrajectorySVM\Data\' fname '_color'];
% foldername =['C:\Users\Pei.Yong\Desktop\ChalearnLookingatPeople2014\UseDenseTrajectorySVM\ValidationData\' fname '_color'];
% for i = 1:length(tracks)
%     fprintf('The %dth track s length is %d.\n',i,size(tracks{i},1));
%     trytracking_showtracks_func(tracks{i},foldername);
% end

% Step1 find all the start and end points of tracks between 60 and 260
endpoints = [];
startpoints = [];
for i = 1:length(tracks)
    frameid = tracks{i}(end,5);
    pos = ( tracks{i}(end,1) + tracks{i}(end,3) )/2;
    if pos>60 & pos<260
        endpoints = [endpoints; frameid pos i];
    end
    
    frameid = tracks{i}(1,5);
    pos = ( tracks{i}(1,1) + tracks{i}(1,3) )/2;
    if pos>60 & pos<260
        startpoints = [startpoints; frameid pos i];
    end
end
% figure();
% hold on;
% scatter(startpoints(:,1),startpoints(:,2));
% scatter(endpoints(:,1),endpoints(:,2));
% hold off;
% Step2 draw a vertical line from that point, find the crossing point with
% other lines

% Step3 pair each end point's crossing point with next start point's
% corssing point. And count the part between them as corssing part.

scoremap = abs( repmat(endpoints(:,1),[1 size(startpoints,1)]) - ...
    repmat(startpoints(:,1)',[size(endpoints,1) 1]));
scoremapindi = scoremap<300;
pair = [];
while sum(scoremapindi(:))~=0
    minindi = find(scoremap==min(scoremap(:)));
    minindi = minindi(1);
    [row,col] = ind2sub(size(scoremap),minindi);
    if startpoints(col,3) ~= endpoints(row,3)%if startpoint and endpoint are from same track
        if tracks{startpoints(col,3)}(end,5) <= endpoints(row,1)%if startpoint's track's end is earlier than endpoint
            scoremap(minindi) = 9999;
        elseif tracks{endpoints(row,3)}(1,5) >= startpoints(col,1)%if endpoint's track's start later than startpoint
            scoremap(minindi) = 9999;
        else
            pair = [pair;endpoints(row,3) startpoints(col,3)];
            scoremap(row,:) = 9999;
            scoremap(:,col) = 9999;
        end
    else
        scoremap(minindi) = 9999;
    end
    scoremapindi = scoremap<300;
end
% Step4 conject pairs tracks
conjectpairs = [];
cpi = 1;
while ~isempty(pair)
    cons = pair(1,:);
    pair(1,:) = [];
    ind = find(pair(:,1) == cons(end));
    while ~isempty(ind)
        cons = [cons pair(ind,2)];
        pair(ind,:) = [];
        ind = find(pair(:,1) == cons(end));
    end
    ind = find(pair(:,2) == cons(1));
    while ~isempty(ind)
        cons = [pair(ind,1) cons];
        pair(ind,:) = [];
        ind = find(pair(:,2) == cons(1));
    end
    
    conjectpairs{cpi} = cons;
    cpi = cpi + 1;
end
newtracks = [];
for i = 1:length(conjectpairs)
    cjp = conjectpairs{i};
    newtracks{i} = tracks{cjp(1)};
    for j = 2:length(cjp);
        if newtracks{i}(end,5) < tracks{cjp(j)}(1,5)
            newtracks{i} = [newtracks{i}; tracks{cjp(j)}];
        else
            replen = newtracks{i}(end,5) - tracks{cjp(j)}(1,5) + 1;
            newtracks{i}(end-replen+1:end,1:4) = (newtracks{i}(end-replen+1:end,1:4)...
                + tracks{cjp(j)}(1:replen,1:4))./2;
            newtracks{i} = [newtracks{i}; tracks{cjp(j)}(replen+1:end,:)];
            
        end
    end
end
indis = [];
for i = 1:length(conjectpairs)
    indis = [indis conjectpairs{i}]; 
end
tracks(indis) = [];
tracks = [tracks newtracks];
% medfilt1
for i = 1:length(tracks)
    tracks{i}(:,1) = medfilt1(tracks{i}(:,1),5);
    tracks{i}(:,2) = medfilt1(tracks{i}(:,2),5);
    tracks{i}(:,3) = medfilt1(tracks{i}(:,3),5);
    tracks{i}(:,4) = medfilt1(tracks{i}(:,4),5);
end
% interp tracks
for i = 1:length(tracks)
    tracks{i} = targetdatainterp( tracks{i} );
end
% draw tracks trajectory
if ifdraw == 1
    figure();
    for i = 1:length(tracks)
        x = tracks{i}(:,5)';
        y = ( tracks{i}(:,1) + tracks{i}(:,3) )/2;
        y = y';
        hold on;

        plot(x,y);
        plot(x(1),y(1),'r.');
        text(x(1),y(1),sprintf('%d.',i));
        plot(x(end),y(end),'r.');
        axis([0 1000 0 320]);
        hold off;
    end
end

fprintf('end tracking..\n');
end

