function [ walks,runs ] = refine_walks_runs( tracks,nimage,walks,runs  )
%UNTITLED2 Summary of this function goes here
%   Add moving slow part
% walks = [];
% runs = [];
candidates = [];
for ti = 1:length(tracks)
    xs = tracks{ti};
    startframe = xs(1,5);
    xs = ( xs(:,1) + xs(:,3) )/ 2;
    xs_ma = xs(2:end) - xs(1:end-1);
    xs_ma = medfilt1(xs_ma,10);

    sig_xs_ma = zeros(length(xs_ma)-1,1);
    for i = 1:length(xs_ma)-1
        if xs_ma(i)*xs_ma(i+1) > 0
            sig_xs_ma(i) = 1;
        end
    end

    sig_xs_ma(1) = 0;
    sig_xs_ma(end) = 0;
    indis = find((sig_xs_ma(2:end) - sig_xs_ma(1:end-1)) ~= 0);
    
    if length(indis)>2
        del = [];
        for i = 1:length(indis)/2
            if abs(xs(indis(i*2)) - xs(indis(i*2-1)))<30
                del = [del i*2-1 i*2];
            end
        end
        indis(del) = [];
    end
    
    
    for i = 1:length(indis)/2
        candidates = [candidates;startframe+indis(i*2-1) startframe+indis(i*2) mean(abs(xs_ma( indis(i*2-1):indis(i*2)))) ...
            xs(indis(i*2-1)) xs(indis(i*2))];
    end

%     distances = abs( xs(indis(:,2)) - xs(indis(:,1)) );
%     indis(distances<30,:) = [];
%     indis = indis + startframe;
%     runs = [runs;indis];

%     xs_ma = abs(xs_ma);
%     for j = 1:length(indis)/2
% %         fprintf('%f, ',mean( xs_ma( indis(j*2-1)+1:indis(j*2) ) ));
%         if mean( xs_ma( indis(j*2-1)+1:indis(j*2) ) )>7.5
%             runs = [runs;7 startframe+indis(j*2-1)+1 startframe+indis(j*2) xs(indis(j*2-1)+1) xs(indis(j*2)+1)];
%         else
%             walks = [walks;6 startframe+indis(j*2-1)+1 startframe+indis(j*2) xs(indis(j*2-1)+1) xs(indis(j*2)+1)];
%         end
%     end
end

indis = zeros(1,nimage);
for i = 1:size(walks,1)
    indis(walks(i,2):walks(i,3)) = 1;
end
for i = 1:size(runs,1)
    indis(runs(i,2):runs(i,3)) = 1;
end

for i = 1:size(candidates,1)
    k = sum(indis(candidates(i,1):candidates(i,2)))/(candidates(i,2)-candidates(i,1)+1);
%     fprintf('%d:%f\n',i,k);
    if k<0.3
        if candidates(i,3)>7.5
            runs = [runs;7 candidates(i,1:2) candidates(i,4:5)];
        else
            walks = [walks;6 candidates(i,1:2) candidates(i,4:5)];
        end
    end
end

end

