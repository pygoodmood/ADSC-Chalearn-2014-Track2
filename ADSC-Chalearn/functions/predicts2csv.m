function [  ] = predicts2csv( predicts, outputname, modelid )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
data = [];
for i = 1:length(predicts)
    data = [data;ones(size(predicts{i},1),1)*modelid(i) predicts{i}];
end
csvwrite(outputname,data);
end

