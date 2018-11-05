function [score] = similarity_score(s1, s2)
%Euclidean distance between SOHs of database and query image
    score = pdist2(s1', s2');
end