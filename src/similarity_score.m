function [score] = similarity_score(P, Q,m)
    N=size(P,1);
    THRESHOLD=3;
    A= zeros(N,N);
    for i=1:N
        for j=1:N
            A(i,j)= 1-(abs(i-j)/THRESHOLD); 
        end
    end
    Z= A*(P+Q);
    Z(Z==0)= 1;
    Z= Z.^m;
    D= (P-Q)./Z;
    score= sqrt( max(D'*A*D,0) );
end