function [  ] = call_keypos_func( foldername )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
fprintf('Human detection start...\n');
addpath('functions');
modellist = rdir('models\*.mat');
% load modellist;
filters = [];
for i = 1:length(modellist)
    load(modellist(i).name);
    models(i).model = model;
    models(i).sample_width = sample_width;
    models(i).sample_height = sample_height;
    
    sh = -2 + sample_height/8;%i
    sw = -2 + sample_width/8;%j
    
    w = model.SVs' * model.sv_coef;
    w = reshape(w, sh, sw, 32);
    
    filters{i} = w;
    thresholds(i) = model.rho - 0.1;
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

%test VOC search
sbin = 8;
interval = 10;
% maxsize = [13 3];%[5 5];
maxsize = [max(a,b) max(a,b)];
padx = max(a,b);%5;
pady = max(a,b);%5;
max_image_size = [240 320];

resdir='Keypose_results\'; % This is where we will save final results using this demo script.
if ~exist(resdir,'dir')
    mkdir(resdir);
end

lambda = 0.1;
alpha = 1;
beta = 0.0001;


outputpath = resdir;
if ~exist(outputpath,'dir')
    mkdir(outputpath);
end
% tic;
imagelist    = dir([foldername,'\*','jpg']);
nimages = length(imagelist);
for i = 1:nimages

    imagename = imagelist(i).name;
%     fprintf('%s\\%s\n',foldername,imagename);

    im_test = imread([foldername, '\', imagename],'jpg');
    im_test = imresize(im_test,[240 320]);
    im_test = rgb2gray(im_test);
    im_test = double(im_test);
    im_test = wlsFilter(im_test, lambda, alpha, beta);%smooth function
    pyra = featpyramid_compact(im_test, sbin, interval, maxsize);

    %Compute Filter Response
    scores = conv_filters(filters, pyra, [1:length(pyra.scales)]);

    %detect
    [det] = scores2det(scores,thresholds);
    [det_win] = det2win(det, pyra.scales, sbin, padx, pady, filter_sizes, max_image_size);

    for i = 1:length(det_win)
        picked_detections = nms(det_win{i}, 0.2);%nms
        plot_boxes{i} = det_win{i}(picked_detections,:);
    end

    save([outputpath,'\','result_of_',imagename,'.mat'], 'plot_boxes','imagename');

end    
% toc;
fprintf('Human detection end...\n');

end

