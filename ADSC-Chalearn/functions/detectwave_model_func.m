function [ results ] = detectwave_model_func( track,foldername )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
h = 70;
w = 58;
sbin = 8;
fealength = 1120;
sample_height = h;
sample_width = w;

tracklength = size(track,1);
feasl = zeros(tracklength,fealength);
feasr = zeros(tracklength,fealength);

lambda = 0.1;
alpha = 1;
beta = 0.0001;

% outputi = 1;
for i = 1:tracklength
% for i = 38:58
    frameid = track(i,5);
    imagename = sprintf('%s/frame%06d.jpg',foldername,frameid);
    im = imread(imagename);
    
%     for model 1245
    box = track(i,:);
%     up = max(1,box(2)*2-50);
%     down = min(480,box(2)*2+110);
%     left = max(1,box(1)*2-50);
%     right = min(640,box(3)*2);
    h = int16(box(4)-box(2)+1);
    up = int16(max(1,box(2)*2-20));
    down = int16(min(480,box(2)*2+h));
    left = int16(max(1,box(1)*2-20));
    right = int16(min(640,box(3)*2+10));
    
    subimage = im(up:down, left:right, :);
    subimage = imresize(subimage, [sample_height sample_width]);
    subimage = rgb2gray(subimage);
    subimage = double(subimage);
    subimage = wlsFilter(subimage, lambda, alpha, beta);%smooth function
    fea = features2(subimage, sbin);
    feasl(i,:) = fea(:);
    
%     left = max(1,box(1)*2);
%     right = min(640,box(3)*2+50);
    left = int16(max(1,box(1)*2-10));
    right = int16(min(640,box(3)*2+20));
    subimage = im(up:down, left:right, :);
    subimage = imresize(subimage, [sample_height sample_width]);
    subimage = rgb2gray(subimage);
    subimage = double(subimage);
    subimage = wlsFilter(subimage, lambda, alpha, beta);%smooth function 
    subimage = fliplr(subimage);
%     figure();imshow(subimage,[]);
%     imwrite(uint8(subimage),sprintf('%06d.bmp',outputi));outputi = outputi + 1;
    
    fea = features2(subimage, sbin);
    feasr(i,:) = fea(:);
    
%     figure();imshow(subimage,[]);
end

load('models/wavemodel/posmodel.mat');
w = model.SVs' * model.sv_coef;
threshold = model.rho;
scoresl = feasl*w;
scoresr = feasr*w;

results1 = scoresl>threshold;
results2= scoresr>threshold;

results = xor(results1,results2);

end

