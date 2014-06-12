function [ walks,runs ] = Tracks2Walk_Run2( tracks,nimage )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
walks = [];
runs = [];
for i = 1:length(tracks)
    xs = tracks{i};
    startframe = xs(1,5);
    xs = ( xs(:,1) + xs(:,3) )/ 2;
    xs_ma = abs(xs(2:end) - xs(1:end-1));
    xs_ma = medfilt1(xs_ma,10);
    xs_mai = double(xs_ma>3);
    xs_mai(xs_ma>5) = -1;
    xs_mai(1) = 0;
    xs_mai(end) = 0;
    xs_mai = medfilt1(xs_mai,5);
    indis = find((xs_mai(2:end) - xs_mai(1:end-1)) ~= 0);
    for j = 1:length(indis)-1
        if mean( xs_ma( indis(j)+1:indis(j+1) ) )>7.5
            runs = [runs;7 startframe-1+indis(j)+1 startframe-1+indis(j+1) xs(indis(j)+1) xs(indis(j+1))];
        elseif mean( xs_ma( indis(j)+1:indis(j+1) ) )>3
            walks = [walks;6 startframe-1+indis(j)+1 startframe-1+indis(j+1) xs(indis(j)+1) xs(indis(j+1))];
        end
    end
end

newrun = [];
newrunid = [];
for i = 1:size(runs,1)
    run_end_frameid = runs(i,3);
    run_end_pos = runs(i,5);
    dis_tem = walks(:,2)-run_end_frameid;
    dis_spa = abs(walks(:,4)-run_end_pos);
    
    dis_tem(dis_tem<=0) = 999;
    indi = find(dis_tem == min(dis_tem));
    if (dis_tem(indi)>0 & dis_tem(indi)<=15 & dis_spa(indi)<10)
        newrunid = [newrunid indi];
    end
end
if ~isempty(newrunid) & walks(newrunid,3)-walks(newrunid,2)<30
    runs = [runs; 7*ones(length(newrunid),1) walks(newrunid,2:end)];
    walks(newrunid,:) = [];
end

[ walks,runs ] = refine_walks_runs( tracks,nimage,walks,runs  );

end

