function [ hugs,kisses,walks ] = refine_hugs_kisses( hugs,kisses,walks )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
for i = 1:size(hugs,1)
    startframe = hugs(i,2);
    endframe = hugs(i,3);
    dis = abs(startframe - walks(:,3));
    if min(dis)<5
        indis = find(dis == min(dis));
        if ~isempty(indis)
            indi = indis(1);
            hugs(i,2) = max(1, hugs(i,2)-( walks(indi,3)-walks(indi,2) ));
            walks(indi,:) = [];
        end
    end
    
    dis = abs(endframe - walks(:,2));
    if min(dis)<5
        indis = find(dis == min(dis));
        if ~isempty(indis)
            indi = indis(1);
            hugs(i,3) = hugs(i,3)+( walks(indi,3)-walks(indi,2) );
            walks(indi,:) = [];
        end
    end
end

for i = 1:size(kisses,1)
    startframe = kisses(i,2);
    endframe = kisses(i,3);
    dis = abs(startframe - walks(:,3));
    if min(dis)<5
        indis = find(dis == min(dis));
        if ~isempty(indis)
            indi = indis(1);
            kisses(i,2) = max(1, kisses(i,2)-( walks(indi,3)-walks(indi,2) ));
            walks(indi,:) = [];
        end
    end
    
    dis = abs(endframe - walks(:,2));
    if min(dis)<5
        indis = find(dis == min(dis));
        if ~isempty(indis)
            indi = indis(1);
            kisses(i,3) = kisses(i,3)+( walks(indi,3)-walks(indi,2) );
            walks(indi,:) = [];
        end
    end
end

end

