%% 
clear;clc;
addpath('functions');
tic;

foldername = 'functions/VideoImages';
if ~exist(foldername)
    mkdir(foldername);
end

cd functions;
inputvideoname = 'C:/Users/Pei.Yong/Desktop/ChalearnLookingatPeople2014/UseDenseTrajectorySVM/ValidationData/Seq08_color.mp4';
commandline = sprintf('Video2Images.exe %s VideoImages',inputvideoname);
system(commandline);
cd ..;

% foldername = 'C:\Users\Pei.Yong\Desktop\ChalearnLookingatPeople2014\UseDenseTrajectorySVM\ValidationData\Seq08_color';

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

% refine predicts with counts(1,:)
% outputname = [fname '_prediction.csv'];
% predicts2csv( predicts, outputname,modelid );
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
% pd(pd(:,1) == 2,:) = [];
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
% pd(pd(:,1) == 5,:) = [];
pd = [pd;jump];
 
% [ ActionPoint ] = DetectActionPoint( foldername,fname );
% pd = [pd;ones(size(ActionPoint,1),1)*2 ActionPoint];


% Action 8 Shakehands
[ shakehands ] = Shakehandsdetection_func( foldername,tracks );
pd = [pd;shakehands];

% Action 9-10 Hug Kiss
% [ hugs, kisses ] = TrajTracks2Hug_Kiss( tracks,foldername );
% pd(pd(:,1) == 9,:) = [];pd(pd(:,1) == 10,:) = [];
% pd = [pd;hugs;kisses];

% Action 11 fight
% [ fights ] = Fightdetection_func( tracks,d ,nimage,walks,runs );
[ fights ] = Fightdetection_Traj_func( d, tracks, nimage );
pd = [pd;fights];

% refine again
pd = refine_points_func(pd,nimage);
[h,i]=sort(pd(:,2));
pd = pd(i,:);
% ids = [2 6 11];
% for i = 1:length(ids)
%     id = ids(i);
%     pd(pd(:,1) == id,2) = pd(pd(:,1) == id,2)-3;
%     pd(pd(:,1) == id,3) = pd(pd(:,1) == id,3)+3;
% end

outputname = 'xxx_prediction.csv';
csvwrite(outputname,pd);

rmdir('Keypose_results','s');
rmdir('Traj_result','s');
rmdir('functions/VideoImages','s');
delete('functions/Traj.txt');

toc;

% fname = 'Seq08';
% gt = load([fname '_groundtruth.csv']);
% r = zeros(11,3);
% for i = 1:11
%     subgt = gt(gt(:,1) == i,2:3);
%     subpd = pd(pd(:,1) == i,2:3);
%     [ recall,accuracy,score ] = cal_overlap(subgt,subpd);
%     r(i,:) = [recall accuracy score];
% end
% scores = r(:,3);
% mean(scores)




