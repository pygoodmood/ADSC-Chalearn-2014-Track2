function [ shakehands ] = Shakehandsdetection_func( foldername,tracks )
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here
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

lambda = 0.1;
alpha = 1;
beta = 0.0001;
sbin = 8;

load('models/shakehandmodel/posmodel.mat');
w = model.SVs' * model.sv_coef;
threshold = model.rho;

imagelist = dir([foldername '/*.jpg']);
candidates_feas = cell(1,size(candidates_track,1));
for i = 1:size(candidates_track,1)
    frameid = candidates_track(i,end);
    im = imread([foldername '/' imagelist(frameid).name]);
    im = imresize(im,[240,320]);
%     figure();imshow(im);
    up = int16(max(candidates_track(i,2), candidates_track(i,7)));
    lenth_long = max(candidates_track(i,4)-candidates_track(i,2),...
        candidates_track(i,9)-candidates_track(i,7));
    down = int16(max(candidates_track(i,2), candidates_track(i,7)) + lenth_long/2);
    left = int16(min(candidates_track(i,3), candidates_track(i,8)));
    right = int16(max(candidates_track(i,1), candidates_track(i,6)));
    
    feas = [];
    if (right - left+1)>=36
        subimage = im(up:down,left:right,:);
        subimage = rgb2gray(subimage);
        candi_height = int16((right - left+1)*36/48);
        for j = 1:5:down-up+1-candi_height
            candi_image = subimage(j:j+candi_height,:,:);
            candi_image = imresize(candi_image, [sample_height sample_width]);
            candi_image = double(candi_image);
            candi_image = wlsFilter(candi_image, lambda, alpha, beta);%smooth function
            fea = features2(candi_image, sbin);
            feas = [feas;fea(:)'];
%             figure();imshow(candi_image,[]);
        end
    else
        subimage = im(up:down,(left+right)/2 - 18:(left+right)/2 + 18,:);
        subimage = rgb2gray(subimage);
        candi_height = 36;
        for j = 1:5:down-up+1-candi_height
            candi_image = subimage(j:j+candi_height,:,:);
            candi_image = imresize(candi_image, [sample_height sample_width]);
            candi_image = double(candi_image);
            candi_image = wlsFilter(candi_image, lambda, alpha, beta);%smooth function
            fea = features2(candi_image, sbin);
            feas = [feas;fea(:)'];
%             figure();imshow(candi_image,[]);
        end
    end
    candidates_feas{i} = feas;
%     figure();imshow(subimage);
end

results = zeros(length(candidates_feas),1);
for i = 1:length(candidates_feas)
    if ~isempty(candidates_feas{i})
        scores = candidates_feas{i}*w;
        if sum(scores>threshold-0.1)>0
            results(i) = 1;
        end
    end
end

results_frameids = candidates_track(results==1,end);

nimage = length(imagelist);
frameindi = zeros(1,nimage);
frameindi(results_frameids) = 1;

frameindi = medfilt1(frameindi);
frameindi(1) = 0;
frameindi(end) = 0;
indis = frameindi(2:end) - frameindi(1:end-1);
pairs = find(indis~=0);

if length(pairs)>2
    del = [];
    for i = 1:(length(pairs)-2)/2
        if pairs(i*2+1)-pairs(i*2) < 20
            del = [del i*2 i*2+1];
        end
    end
    pairs(del) = [];
end



shakehands = [];
for i = 1:length(pairs)/2
    shakehands = [shakehands; 8 pairs(i*2-1) pairs(i*2)];
end

lens = shakehands(:,3)-shakehands(:,2);
shakehands(lens<6,:) = [];

end

