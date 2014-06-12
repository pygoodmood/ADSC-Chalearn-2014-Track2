function [  ] = Trajpooling_func( d )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
% clear;clc
fprintf('Traj pooling strat...\n');
c = load('Traj_models&codebooks/Chalearn_Traj_CodeBookSize10001.mat');
CodeBook_Traj = c.centres;
c = load('Traj_models&codebooks/Chalearn_MBH_CodeBookSize10001.mat');
CodeBook_MBH = c.centres;
clear('c');

% path = 'C:\Users\Pei.Yong\Desktop\ChalearnLookingatPeople2014\UseDenseTrajectorySVM\ValidationData\';
% trajlist = dir([path '*.txt']);

% ti = 2;
% d = load(['functions/' Trajfilename]);
outputpath = ['Traj_result/encodingdata'];
if(~exist(outputpath))
    mkdir(outputpath);
end

pooling_length = 15;

for i = d(1,1):pooling_length:d(end,1)
    indis = [];
    for ii = 1:pooling_length
        indis = [indis; find(d(:,1) == i+ii-1)];
    end
    ds = d(indis,232:261);%Trajec
    norm = sqrt(sum(ds.^2,2));
    ds = ds./repmat(max(norm,1e-10),1,size(ds,2));
    
    [W]=EuDist2(ds,CodeBook_Traj);
    [junk,I]=min(W,[],2);
    data.VW_TRJ1000 = I;
    [H] = VW2HIST(I, 1000);
    data.Hist_TRJ1000 = H;
    
    ds  = d(indis,40:231);%MBH
    norm = sqrt(sum(ds.^2,2));
    ds = ds./repmat(max(norm,1e-10),1,size(ds,2));
    [W]=EuDist2(ds,CodeBook_MBH);
    [junk,I]=min(W,[],2);
    data.VW_MBH1000 = I;
    [H] = VW2HIST(I, 1000);
    data.Hist_MBH1000 = H;
    
    clear ds;
    
    save_name = sprintf( '%s\\frame%06d.mat',outputpath,i);
%     disp('---');
    save(save_name,'data');
end
clear d;
fprintf('Traj pooling end...\n');
end

