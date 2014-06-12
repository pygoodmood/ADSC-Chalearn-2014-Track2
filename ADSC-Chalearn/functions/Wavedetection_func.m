function [ waves ] = Wavedetection_func( d,foldername,tracks,walks,runs )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
[ track ] = ProduceWaveCandi_func(foldername, tracks,walks,runs );
[ results ] = detectwave_model_func( track,foldername );


nimage = length(dir([foldername '/*.jpg']));
frameindi = zeros(1,nimage);
frameindi(track(results==1,5)) = 1;

frameindi = medfilt1(frameindi,5);
frameindi(1) = 0;
frameindi(end) = 0;
indis = frameindi(2:end) - frameindi(1:end-1);
pairs = find(indis~=0);
waves = [];
for i = 1:length(pairs)/2
    waves = [waves; 1 pairs(i*2-1) pairs(i*2)];
end

if ~isempty(waves)
    lens = waves(:,3)-waves(:,2);
    waves(lens<3,:) = [];
end

[ wave2 ] = detectwave_traj_func( d,track ,nimage);
waves = [waves;wave2];

end

