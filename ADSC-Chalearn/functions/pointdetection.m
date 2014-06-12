function [ points ] = pointdetection( foldername,tracks,walks,runs )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
[ track ] = ProducePointCandi_func(foldername, tracks,walks,runs );
[ results1 ] = detectpoint_model1245_func( track,foldername );
[ results2 ] = detectpoint_model3_func( track,foldername );
results = results1 | results2;

nimage = length(dir([foldername '/*.jpg']));
frameindi = zeros(1,nimage);
frameindi(track(results==1,5)) = 1;

frameindi = medfilt1(frameindi);
frameindi(1) = 0;
frameindi(end) = 0;
indis = frameindi(2:end) - frameindi(1:end-1);
pairs = find(indis~=0);
points = [];
for i = 1:length(pairs)/2
    points = [points; 2 pairs(i*2-1) pairs(i*2)];
end

lens = points(:,3)-points(:,2);
points(lens<8,:) = [];

end

