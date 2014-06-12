function [ hugs, kisses ] = TrajTracks2Hug_Kiss( tracks,foldername )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
hugs = [];
kisses = [];
hugkiss = [];
hugkisstrackid = [];
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
            dis = (overlapa(:,1)+overlapa(:,3))/2 - (overlapb(:,1)+overlapb(:,3))/2;
            dis = medfilt1(dis);
            near_dis = max(overlapa(:,1),overlapb(:,1)) - min(overlapa(:,3),overlapb(:,3));
%             avewidth = (sum(overlapa(:,3) - overlapa(:,1)) + sum(overlapb(:,3) - overlapb(:,1)))/...
%                 ( 2*(endm-startm+1) );
%             indivec = abs(dis) - avewidth<5 & abs(dis) - avewidth>-10;
            
            indivec = abs(dis)<50 & near_dis<5;
            indivec(1) = 0;indivec(end) = 0;
            indis = find((indivec(2:end) - indivec(1:end-1)) ~= 0);
            for k = 1:length(indis)/2
%                 if sum( dis(indis(k*2-1)+1:indis(k*2)) )/(indis(k*2)- indis(k*2-1))>20 | ...
%                         sum( dis(indis(k*2-1)+1:indis(k*2)) )/(indis(k*2)- indis(k*2-1))<-20
                    hugkiss = [hugkiss;startm+indis(k*2-1) startm+indis(k*2)-1];
                    hugkisstrackid = [hugkisstrackid; i j];
%                 end
            end
        end
    end
end
% hugs = [ones(size(hugkiss),1)*9 hugkiss];
% kisses = [ones(size(hugkiss),1)*10 hugkiss];

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
addpath('functions');
modellist = rdir('models\kissmodel\*.mat');
filters = [];
for i = 1:length(modellist)
    load(modellist(i).name);
    models(i).model = model;
    models(i).sample_width = sample_width;
    models(i).sample_height = sample_height;
    
    sh = -2 + sample_height/8;%i
    sw = -2 + sample_width/8;%j
    
    w = model.SVs' * model.sv_coef;
    w = reshape(w, sh, sw, 32);
    
    filters{i} = w;
    thresholds(i) = model.rho + 0.0;
    filter_sizes{i} = [sh sw];

    if sh>7
        a = 1 + ceil( (sh-7)/2 );
    else
        a = 1;
    end

    if sw>9
        b = 1 + ceil( (sw-9)/2 );
    else
        b = 1;
    end
    
    as(i) = a;
    bs(i) = b;
    clear model sample_width sample_height;
end

%test VOC search
sbin = 8;
interval = 10;
% maxsize = [13 3];%[5 5];
maxsize = [max(a,b) max(a,b)];
padx = max(a,b);%5;
pady = max(a,b);%5;
max_image_size = [240 320];


imagelist    = dir([foldername,'\*','jpg']);
lambda = 0.1;
alpha = 1;
beta = 0.0001;
for i = 1:size(hugkiss,1)
    startframe = hugkiss(i,1);
    endframe = hugkiss(i,2);
    
    tracka = tracks{hugkisstrackid(i,1)};
    trackb = tracks{hugkisstrackid(i,2)};
    boxesa = tracka(tracka(:,5)>=startframe & tracka(:,5)<=endframe ,:);
    boxesb = trackb(trackb(:,5)>=startframe & trackb(:,5)<=endframe ,:);

    combinebox = [ min(boxesa(:,1),boxesb(:,1)) min(boxesa(:,2),boxesb(:,2)) ...
        max(boxesa(:,3),boxesb(:,3)) max(boxesa(:,4),boxesb(:,4))];
    counts = zeros(endframe-startframe+1,1);
    for j = 1:endframe - startframe +1
        imagename = imagelist(startframe + j -1).name;
%         fprintf('%s\\%s\n',foldername,imagename);

        im_test = imread([foldername, '\', imagename],'jpg');
        im_test = imresize(im_test,[240 320]);
        im_test = rgb2gray(im_test);
        im_test = double(im_test);
        im_test = wlsFilter(im_test, lambda, alpha, beta);
        
%         im_test = im_test(combinebox(j,2):combinebox(j,4), combinebox(j,1):combinebox(j,3));
        xc = (combinebox(j,1)+combinebox(j,3))/2;
        
        left = max(1,int16(combinebox(j,2))-30);
        right = min(320,int16(combinebox(j,2))+30);
        up = max(1,int16(xc)-60);
        down = min(240,int16(xc)+60);
        im_test = im_test(left:right,up:down);
%         im_test = fliplr(im_test);
%         figure();imshow(im_test,[]);
        
        pyra = featpyramid_single_compact(im_test, sbin, interval, maxsize);

        %Compute Filter Response
        scores = conv_filters(filters, pyra, [1:length(pyra.scales)]);

        %detect
        [det] = scores2det(scores,thresholds);
        [det_win] = det2win(det, pyra.scales, sbin, padx, pady, filter_sizes, max_image_size);

        for k = 1:length(det_win)
            picked_detections = nms(det_win{k}, 0.4);%nms
            plot_boxes{k} = det_win{k}(picked_detections,:);
        end
        counts(j) = size(plot_boxes{end},1);
%         showboxes(im_test,plot_boxes{end});
%         figure(1);imshow(im_test,[]);
%         pause(0.1);
    end
%     i
%     sum(counts)
    len = endframe-startframe+1;
    if sum(counts)/len > 0.1 & sum(counts(int16(len/3):int16(len*2/3)))~=0
        kisses = [kisses;10 hugkiss(i,:)];
    else
        hugs = [hugs;9 hugkiss(i,:)];
    end
%     ifkiss_Trj(d, startframe, endframe, combinebox)
end

if ~isempty(hugs)
    hugs(hugs(:,3)-hugs(:,2)<6,:) = [];
end
if ~isempty(kisses)
    kisses(kisses(:,3)-kisses(:,2)<6,:) = [];
end
end

