function [histogram] = VW2HIST(VWS, num_centers)
histogram = zeros(num_centers,1);    
for i = 1 : length(VWS)
    histogram(VWS(i)) = histogram(VWS(i)) + 1;
end
histogram = double(histogram) / double(sum(histogram));

end