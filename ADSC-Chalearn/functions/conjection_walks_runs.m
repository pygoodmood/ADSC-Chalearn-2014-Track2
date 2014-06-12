function [ walks,runs ] = conjection_walks_runs( walks,runs,nimage )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
frameindi = zeros(1,nimage);
for i= 1:size(runs,1)
    frameindi(runs(i,2)+1:runs(i,3)) = 1;
end
frameindi(1) = 0;
frameindi(end) = 0;
indis = frameindi(2:end) - frameindi(1:end-1);
pairs = find(indis~=0);

poses = zeros(1,length(pairs));
for i = 1:length(pairs)/2
    s_framed_id = pairs(i*2-1);
    e_framed_id = pairs(i*2);
    inds = find(runs(:,2) == s_framed_id);
    s_ind = 0;
    if ~isempty(inds)
        s_ind = inds(1);
    end
    
    find(runs(:,3) == e_framed_id);
    e_ind = 0;
    if ~isempty(inds)
        e_ind = inds(1);
    end
    
    if s_ind==e_ind && s_ind ~= 0
        poses(i*2-1:i*2) = runs(s_ind,4:5);
    end
end


if length(pairs)>2
    del = [];
    for i = 1:(length(pairs)-2)/2
        if poses(i*2+1)~=0 & poses(i*2)~=0
            if pairs(i*2+1) - pairs(i*2) + poses(i*2+1) - poses(i*2) <50
                del = [del i*2 i*2+1 ];
            end
        end
    end
    pairs(del) = [];
end
runs = [];
for i = 1:length(pairs)/2
    runs = [runs; 7 pairs(i*2-1) pairs(i*2)];
end

% walks
frameindi = zeros(1,nimage);
for i= 1:size(walks,1)
    frameindi(walks(i,2)+1:walks(i,3)) = 1;
end
frameindi(1) = 0;
frameindi(end) = 0;
indis = frameindi(2:end) - frameindi(1:end-1);
pairs = find(indis~=0);

poses = zeros(1,length(pairs));
for i = 1:length(pairs)/2
    s_framed_id = pairs(i*2-1);
    e_framed_id = pairs(i*2);
    inds = find(walks(:,2) == s_framed_id);
    s_ind = 0;
    if ~isempty(inds)
        s_ind = inds(1);
    end
    
    find(walks(:,3) == e_framed_id);
    e_ind = 0;
    if ~isempty(inds)
        e_ind = inds(1);
    end
    
    if s_ind==e_ind && s_ind ~= 0
        poses(i*2-1:i*2) = walks(s_ind,4:5);
    end
end

if length(pairs)>2
    del = [];
    for i = 1:(length(pairs)-2)/2
        if poses(i*2+1)~=0 & poses(i*2)~=0
            if pairs(i*2+1) - pairs(i*2) + abs(poses(i*2+1) - poses(i*2)) <50
                del = [del i*2 i*2+1 ];
            end
        end
    end
end
pairs(del) = [];
walks = [];
for i = 1:length(pairs)/2
    walks = [walks; 6 pairs(i*2-1) pairs(i*2)];
end

end

