function [ predicts, modelid ] = Trajdetect_func(encodedfoldername)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
% clear;clc;

path = ['Traj_result/' encodedfoldername];
list = dir([path '\*.mat']);
fea = [];
for i = 1:length(list)
    d = load([path '\' list(i).name]);
    d = d.data;
    fea = [fea;[ d.Hist_MBH1000', d.Hist_TRJ1000']];
end
label = zeros(size(fea,1),1);

predicts=[];
modelid = [3];
% modelid = [1 2 3 4 5 6 7 8 9 10 11];
	for mi = 1:length(modelid)
	    load(sprintf('Traj_models&codebooks/2class_%02d_model.mat',modelid(mi)));
	%     ti = 2;
	    
	    [predict_label, accuracy, dec_values] = svmpredict(label, fea, model);
	    % predict_label(1:30,2) = predict_label(end-29:end,1);
	    % % predict_label(end-29:end,:) = [];
	    predict_label = (predict_label == 1);
	    
	%     gt_sub = gt(gt(:,1) == mi,2:3);
	    predict_sub = find(predict_label == 1);
	    predict_sub = [(predict_sub-1)*15 (predict_sub+1)*15];
	    
	%     [ recall,accuracy ] = cal_overlap( gt_sub, predict_sub );
	%     r = [r; recall accuracy];
	    
	    predicts{mi} = predict_sub;
	end
% r = r';
% save(sprintf('predicts_%s.mat',trajlist(ti).name(6:10)),'predicts');

end

