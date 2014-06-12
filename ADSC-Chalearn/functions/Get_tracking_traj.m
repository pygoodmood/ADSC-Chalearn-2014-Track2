function [ coords, coords_of_two ] = Get_tracking_traj( foldername )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
addpath('functions');

outputpath=['Keypose_results\']; % This is where we will save final results using this demo script.

% modellist = rdir('models\*.mat');
% for i = 1:length(modellist)
%     fprintf('%s\n',modellist(i).name);
% end

imagelist    = dir([foldername,'\*','jpg']);
nimages = length(imagelist);

coords = zeros(3,nimages);
coords_of_two = [];
for i = 1:nimages
    imagename = imagelist(i).name;
    load([outputpath,'\','result_of_',imagename,'.mat']);
    x = 0;
    y = 0;
    n = 0;
    boxes = plot_boxes{end};
    for j = 1:size(boxes,1)    
        x = (boxes(j,1) + boxes(j,3))/2;
        y = (boxes(j,2) + boxes(j,4))/2;
        n = n + 1;
    end
    if n~=0
        x = x/n;
        y = y/n;
    end
    coords(1,i) = x;
    coords(2,i) = y;
    coords(3,i) = n;
    
    if n == 2
        coords_of_two = [coords_of_two;ones(n,1)*i boxes];
    end
end

coords(1,:) = medfilt1( coords(1,:) );
coords(2,:) = medfilt1( coords(2,:) );

end