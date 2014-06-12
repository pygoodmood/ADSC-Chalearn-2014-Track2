function [ walks,runs ] = Tracks2Walk_Run( tracks )
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
    xs_mai = xs_ma>3;
    xs_mai(1) = 0;
    xs_mai(end) = 0;
    xs_mai = medfilt1(xs_mai,5);
    indis = find((xs_mai(2:end) - xs_mai(1:end-1)) ~= 0);
%     indis = indis;
    for j = 1:length(indis)/2
        if mean( xs_ma( indis(j*2-1)+1:indis(j*2) ) )>8.5
            runs = [runs;7 startframe-1+indis(j*2-1)+1 startframe-1+indis(j*2)];
        else
            walks = [walks;6 startframe-1+indis(j*2-1)+1 startframe-1+indis(j*2)];
        end
    end
end

end

