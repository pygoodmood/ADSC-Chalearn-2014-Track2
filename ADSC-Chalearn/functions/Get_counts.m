function [ counts ] = Get_counts( foldername )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
addpath('functions');

outputpath=['Keypose_results\'];  % This is where we will save final results using this demo script.

modellist = rdir('models\*.mat');
for i = 1:length(modellist)
    fprintf('%s\n',modellist(i).name);
end

imagelist    = dir([foldername,'\*','jpg']);
nimages = length(imagelist);

counts = zeros(length(modellist),nimages);
for i = 1:nimages
    imagename = imagelist(i).name;
    load([outputpath,'\','result_of_',imagename,'.mat']);
    for j = 1:length(plot_boxes)    
        if ~isempty(plot_boxes{j})
            counts(j,i) = size(plot_boxes{j},1);
        end
    end
    close all;
end

counts(1,:) = (counts(1,:)~=0);

end

