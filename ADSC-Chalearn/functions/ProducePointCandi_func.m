function [ track ] = ProducePointCandi_func(foldername, tracks,walks,runs )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
% foldername = ['data/' fname '_color'];
nimage = length(dir([foldername '/*.jpg']));
ntracks = length(tracks);

indis = zeros(1,nimage);
for i = 1:ntracks
    indis(tracks{i}(1,5):tracks{i}(end,5)) = indis(tracks{i}(1,5):tracks{i}(end,5)) + 1;
end
indis = (indis == 1);

movingpart = [walks;runs];
for i = 1:size(movingpart,1)
    indis(movingpart(i,2):movingpart(i,3)) = 0;
end

candidates_track = [];
for i = 1:ntracks
    track = tracks{i};
    indis_part = indis(track(1,5):track(end,5));
    track = track(find(indis_part==1),:);
    candidates_track = [candidates_track;track];
end

[Y,I] = sort(candidates_track(:,5));
candidates_track = candidates_track(I,:);
track = candidates_track;

end

