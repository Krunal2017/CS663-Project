im=imread('../src/1.jpg');
[m n p]=size(im);
window_size=5;
fmat=zeros((m-4)*(n-4),25,p);
f = waitbar(0,"Please Wait...");
tic;
for iter=1:p
    msg=strcat('Processing Channel-',num2str(iter));
    f = waitbar(iter/p,f,msg);
    fmat(:,:,iter)=computeFeatures(im(:,:,iter),m,n,window_size);
end
close(f);
toc;
[coeff1,score1,latent1]=pca(fmat(:,:,1));
[coeff2,score2,latent2]=pca(fmat(:,:,2));
[coeff3,score3,latent3]=pca(fmat(:,:,3));
cfmat=zeros(25,2,3);
e1=coeff1(:,1);
e2=coeff1(:,2);
t1=fmat(:,:,1)*e1;
t2=fmat(:,:,1)*e2;
tx=cat(2,t1,t2);
clusters=20;
channel1=fmat(:,:,1);
atoms=[];
idx=kmeans(tx,clusters); % idx contains the local textural representations of the texture atoms.
for iter=1:clusters
    indices=find(idx==iter);
    temp=mean(tx(indices,:)); % performing mean on clusters should give texture representative atom of the local textures(distinct).
    atoms=cat(1,atoms,temp);
end
%     mean=sum(channel1(indices))/length(indices);

function feature_matrix=computeFeatures(im,m,n,window_size)
diff=(window_size-1)/2;
feature_matrix=[];
x1=1;
y1=1;
x2=1;
y2=1;

f=waitbar(0,"Please wait...");
% Ignoring boundary conditions for now.
for i=3:m-2
    msg='Processing...';
    f = waitbar(i/(m-2),f,msg);
    for j=3:n-2
        if i+diff>m
            x2=m;
        else
            x2=i+diff;
        end
        if i-diff<1
            x1=1;
        else
            x1=i-diff;
        end
        if j+diff>n
            y2=n;
        else
            y2=j+diff;
        end
        if j-diff<1
            y1=1;
        else
            y1=j-diff;
        end
        
        A=im([x1:x2],[y1:y2]);
        [m1 n1]=size(A);
        layer2=A(1,1:4);
        layer2=cat(2,layer2,transpose(A(1:5,5)));
        layer2=cat(2,layer2,A(5,1:4));
        layer2=cat(2,layer2,transpose(A(2:4,1)));
        sorted_layer2=sort(layer2); % Sorting the square rings around center pixel.
        layer1=A(2,2:4);
        layer1=cat(2,layer1,A(4,2:4));
        layer1=cat(2,layer1,[A(3,2),A(3,4)]);
        sorted_layer1=sort(layer1); 
        local_vector=cat(2,A(3,3),sorted_layer1);
        local_vector=cat(2,local_vector,sorted_layer2);
        
        feature_matrix=cat(1,feature_matrix,local_vector);
%         disp(A);
%         disp(local_vector);
    end
end
close(f);
end
