function [ results ] = detectpoint_model1245_func( track,foldername )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
h = 80;
w = 72;
sbin = 8;
fealength = 1792;
sample_height = h;
sample_width = w;

tracklength = size(track,1);
feasl = zeros(tracklength,fealength);
feasr = zeros(tracklength,fealength);

lambda = 0.1;
alpha = 1;
beta = 0.0001;

for i = 1:tracklength
    frameid = track(i,5);
    imagename = sprintf('%s/frame%06d.jpg',foldername,frameid);
    im = imread(imagename);
    
%     for model 1245
    box = track(i,:);
    up = int16(max(1,box(2)*2-50));
    down = int16(min(480,box(2)*2+110));
    left = int16(max(1,box(1)*2-50));
    right = int16(min(640,box(3)*2));
    
    subimage = im(up:down, left:right, :);
    subimage = imresize(subimage, [sample_height sample_width]);
    subimage = rgb2gray(subimage);
    subimage = double(subimage);
    subimage = wlsFilter(subimage, lambda, alpha, beta);%smooth function
    fea = features2(subimage, sbin);
    feasl(i,:) = fea(:);
    
    left = int16(max(1,box(1)*2));
    right = int16(min(640,box(3)*2+50));
    subimage = im(up:down, left:right, :);
    subimage = imresize(subimage, [sample_height sample_width]);
    subimage = rgb2gray(subimage);
    subimage = double(subimage);
    subimage = wlsFilter(subimage, lambda, alpha, beta);%smooth function 
    subimage = fliplr(subimage);
    fea = features2(subimage, sbin);
    feasr(i,:) = fea(:);
    
%     figure();imshow(subimage,[]);
end

modellist = dir('models/pointmodel/pos*model.mat');
modellist(3) = [];

ws = zeros(fealength,length(modellist));
thresholds = zeros(1,length(modellist));
for i = 1:length(modellist)
    load(['models/pointmodel/' modellist(i).name]);
    w = model.SVs' * model.sv_coef;
    ws(:,i) = w';
    thresholds(i) = model.rho-0.1;
end

scoresl = feasl*ws;
scoresr = feasr*ws;

for i = 1:length(thresholds)
    scoresl(:,i) = scoresl(:,i)>thresholds(i);
    scoresr(:,i) = scoresr(:,i)>thresholds(i);
end

results1 = zeros(tracklength,1);
results2 = zeros(tracklength,1);

for i = 1:length(thresholds)
    results1 = results1 | scoresl(:,i);
    results2 = results2 | scoresr(:,i);
end

results = xor(results1,results2);

end

