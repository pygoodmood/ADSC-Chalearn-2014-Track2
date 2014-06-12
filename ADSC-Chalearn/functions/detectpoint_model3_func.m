function [ results ] = detectpoint_model3_func( track,foldername )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
modellist = dir('models/pointmodel/pos*model.mat');
modellist = modellist(3);
% load modellist;
filters = [];
for i = 1:length(modellist)
    load(['models/pointmodel/' modellist(i).name]);
    models(i).model = model;
    models(i).sample_width = sample_width;
    models(i).sample_height = sample_height;
    
    sh = int16(-2 + sample_height/8);%i
    sw = int16(-2 + sample_width/8);%j
    
    w = model.SVs' * model.sv_coef;
    w = reshape(w, sh, sw, 32);
    
    filters{i} = w;
    thresholds(i) = model.rho + 0.0;
    filter_sizes{i} = [sh sw];

    if sh>7
        a = 1 + ceil( (sh-7)/2 );
    else
        a = 1;
    end

    if sw>9
        b = 1 + ceil( (sw-9)/2 );
    else
        b = 1;
    end
    
    as(i) = a;
    bs(i) = b;
    clear model sample_width sample_height;
end

sbin = 8;

lambda = 0.1;
alpha = 1;
beta = 0.0001;

interval = 1;
maxsize = [max(a,b) max(a,b)];
padx = max(a,b);%5;
pady = max(a,b);%5;
max_image_size = [240 320];

tracklength = size(track,1);
results = zeros(tracklength,1);
for i = 1:tracklength
    frameid = track(i,5);
    imagename = sprintf('%s/frame%06d.jpg',foldername,frameid);
    im = imread(imagename);
    
%     for model 1245
    box = track(i,:);
    up = int16(max(1,box(2)*2-100));
    down = int16(min(480,box(2)*2+50));
    left = int16(max(1,box(1)*2-10));
    right = int16(min(640,box(3)*2+10));
    
    subimage = im(up:down, left:right, :);
    subimage = imresize(subimage, 0.5);
    subimage = rgb2gray(subimage);
    subimage = double(subimage);
    subimage = wlsFilter(subimage, lambda, alpha, beta);%smooth function
%     fea = features2(subimage, sbin);
    pyra = featpyramid_single1_compact(subimage, sbin, interval, maxsize);
    %Compute Filter Response
    scores = conv_filters(filters, pyra, [1:length(pyra.scales)]);

    %detect
    [det] = scores2det(scores,thresholds-0.05);
    [det_win] = det2win(det, pyra.scales, sbin, padx, pady, filter_sizes, max_image_size);
    for j = 1:length(det_win)
        picked_detections = nms(det_win{j}, 0.4);%nms
        plot_boxes{j} = det_win{j}(picked_detections,:);
    end
    if ~isempty(plot_boxes{1})
        results(i) = 1;
    end
    
    subimage = fliplr(subimage);
    pyra = featpyramid_single1_compact(subimage, sbin, interval, maxsize);
    %Compute Filter Response
    scores = conv_filters(filters, pyra, [1:length(pyra.scales)]);

    %detect
    [det] = scores2det(scores,thresholds-0.05);
    [det_win] = det2win(det, pyra.scales, sbin, padx, pady, filter_sizes, max_image_size);
    for j = 1:length(det_win)
        picked_detections = nms(det_win{j}, 0.4);%nms
        plot_boxes{j} = det_win{j}(picked_detections,:);
    end
    if ~isempty(plot_boxes{1})
        results(i) = 1;
    end
    
%     figure();imshow(subimage,[]);
end

end

