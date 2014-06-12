function [ fights ] = Fightdetection_Traj_func( d, tracks, nimage )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%  produce candidates tracking boxes
c = load('Traj_models&codebooks/Chalearn_XYs_CodeBookSize1000.mat');
CodeBook_XYs = c.centres;
clear('c');

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

            indivec = dis<110 & dis>10;

            dis_change = abs(dis(2:end)-dis(1:end-1));
            indivec(1:end-1) = indivec(1:end-1) & dis_change<15;
            candidates_track = [candidates_track; overlapa(indivec,:) overlapb(indivec,:)];
        end
    end
end

candi_frames = candidates_track(:,end);
frameindi = zeros(1,nimage);
frameindi(candi_frames) = 1;

frameindi(1) = 0;
frameindi(end) = 0;
frameindi_diff = frameindi(2:end) - frameindi(1:end-1);
pairs = find(frameindi_diff~=0);

span = [];
for i = 1:length(pairs)/2
    span = [span; 11 pairs(i*2-1) pairs(i*2)];
end
lens = span(:,3) - span(:,2);
span(lens<15,:) = [];
span(:,2) = span(:,2)+1;

% pooling
feas = [];
frameids = [];

pooling_length = 15;
for pi = 1:size(span,1)
    for i = span(pi,2):5:span(pi,3)-15
%         indis = [];
        data_XYs = [];
        for ii = 1:pooling_length
            frameid = i+ii-1;
            indis = d(:,1) == frameid;
            ds = d(indis,:);%Trajec
            XYs = ds(:,8:39);
            Xs = XYs(:,1:2:29);%Left to right
            Ys = XYs(:,2:2:30);%Up to down

            candi_indi = find(candidates_track(:,end) == frameid);
            if ~isempty(candi_indi)
                candi_indi = candi_indi(1);
                left = 2*min(candidates_track(candi_indi,1),candidates_track(candi_indi,6));
                right = 2*max(candidates_track(candi_indi,3),candidates_track(candi_indi,8));
                up = 2*min(candidates_track(candi_indi,2),candidates_track(candi_indi,7));
                down = 2*max(candidates_track(candi_indi,4),candidates_track(candi_indi,9));
                Xs = (Xs-left)./max(1,right-left);
                Ys = (Ys-up)./max(1,down-up);
                data_XYs = [data_XYs;Xs Ys];
            end
        end

        %%

        norm = sqrt(sum(data_XYs.^2,2));
        data_XYs = data_XYs./repmat(max(norm,1e-10),1,size(data_XYs,2));

        [W]=EuDist2(data_XYs,CodeBook_XYs);
        [junk,I]=min(W,[],2);
        data.VW_XYs1000 = I;
        [H] = VW2HIST(I, 1000);
        data.Hist_XYs1000 = H;
        
        feas = [feas;H'];
        frameids = [frameids;i];
%         clear data;

%         save_name = sprintf( 'pos/%06d.mat',posi);
%         posi = posi + 1;
%         disp('---');
%         save(save_name,'data');
    end
end
load('models/fightmodel/fight_traj_model.mat');
threshold = model.rho;
W = model.SVs' * model.sv_coef;
scores = feas*W;
result = scores>threshold;

fightframeid = frameids(result);

fightframeindi = zeros(1,nimage);
for i = 1:length(fightframeid)
    fightframeindi(fightframeid(i)-15:fightframeid(i)+15) = 1;
end

fightframeindi(1) = 0;
fightframeindi(end) = 0;
fightframeindi_diff = fightframeindi(2:end) - fightframeindi(1:end-1);
fightpairs = find(fightframeindi_diff~=0);

fights = [];
for i = 1:length(fightpairs)/2
    fights = [fights; 11 fightpairs(i*2-1) fightpairs(i*2)];
end
lens = fights(:,3) - fights(:,2);
fights(lens<30,:) = [];

end

