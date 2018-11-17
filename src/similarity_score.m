function [score] = similarity_score(P, Q,m)
%Euclidean distance between SOHs of database and query image
%     score = pdist2(P', Q');
% function dist= QC(P,Q,A,m)
    N=size(P,1);
    THRESHOLD=3;
    A= zeros(N,N);
%     A=1-abs(P-Q')/THRESHOLD;
    for i=1:N
        for j=1:N
            A(i,j)= 1-(abs(i-j)/THRESHOLD); 
        end
    end
    Z= A*(P+Q);
    % 1 can be any number as Z_i==0 iff D_i=0
    Z(Z==0)= 1;
    Z= Z.^m;
    D= (P-Q)./Z;
    % max is redundant if A is positive-semidefinite
    score= sqrt( max(D'*A*D,0) );
end