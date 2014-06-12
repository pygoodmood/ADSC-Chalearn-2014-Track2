function [ ] = main_func( inputvideoname,outputfilename )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
addpath('functions');
% tic;

foldername = 'functions/VideoImages';
if ~exist(foldername)
    mkdir(foldername);
end

cd functions;
% inputvideoname = 'C:/Users/Pei.Yong/Desktop/ChalearnLookingatPeople2014/UseDenseTrajectorySVM/ValidationData/Seq08_color.mp4';
commandline = sprintf('Video2Images.exe %s VideoImages',inputvideoname);
system(commandline);
cd ..;

%1 Run key pose function. Get counts.
call_keypos_func( foldername );

% use SemanticTrajectory.exe to calculate the trajectory
Trajfilename = ['Traj.txt'];
imagelist    = dir([foldername,'\*','jpg']);
nimage = length(imagelist);
commandline = sprintf('SemanticTrajectory.exe VideoImages %s 1 %d',Trajfilename, nimage);
cd functions;
system(commandline);
cd ..;

% call pooling function
d = load(['functions/Traj.txt']);
Trajpooling_func( d );

encodedfoldername = ['encodingdata'];
[ predicts, modelid ] = Trajdetect_func(encodedfoldername);

pd = [];
for i = 1:length(predicts)
    pd = [pd;ones(size(predicts{i},1),1)*modelid(i) predicts{i}];
end

% Get Traj and tracks
[ tracks ] = tracking_main_func();

% Action 6-7 Walk Run % Action 9-10 Hug Kiss
[ walks,runs ] = Tracks2Walk_Run2( tracks,nimage );

[ hugs, kisses ] = TrajTracks2Hug_Kiss( tracks,foldername );
[ hugs,kisses,walks ] = refine_hugs_kisses( hugs,kisses,walks );
pd = [pd;hugs;kisses];

[ walks,runs ] = conjection_walks_runs( walks,runs,nimage );
pd = [pd;walks;runs];

% Action 1 Wave
[ waves ] = Wavedetection_func( d,foldername,tracks,walks,runs );
pd(pd(:,1) == 1,:) = [];
pd = [pd;waves];

% Action 2 Point
[ points ] = pointdetection( foldername,tracks,walks,runs );
pd = [pd;points];

% Refine Action 3 clap
[ track ] = ProduceWaveCandi_func(foldername, tracks,walks,runs );
claps = pd(pd(:,1)==3,:);
claps_refined = refine_clap_func( d,track,claps,nimage );
pd(pd(:,1)==3,:) = [];
pd = [pd;claps_refined];

% Action 4 Crouch
[ crouch ] = Traj2Crouch(d);
pd(find(pd(:,1) == 4),:) = [];
pd = [pd;crouch];

% Action 5 Jump
 [jump ] = TrajTrack2Jump( d, tracks );
pd = [pd;jump];

% Action 8 Shakehands
[ shakehands ] = Shakehandsdetection_func( foldername,tracks );
pd = [pd;shakehands];

% Action 11 fight
[ fights ] = Fightdetection_Traj_func( d, tracks, nimage );
pd = [pd;fights];

% refine again
pd = refine_points_func(pd,nimage);
[h,i]=sort(pd(:,2));
pd = pd(i,:);

% outputname = 'xxx_prediction.csv';
csvwrite(outputfilename,pd);

% rmdir('Keypose_results','s');
% rmdir('Traj_result','s');
% rmdir('functions/VideoImages','s');
% delete('functions/Traj.txt');

% toc;

end

