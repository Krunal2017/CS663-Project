% im=imread('../src/1.jpg');
im=imread('../SampleImages/Butterfly/10.jpg');
[m n p]=size(im);
res_im=im(3:m-2,3:n-2,1:3);
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

% using myPCA method

lab_image=[];
lab_image=cat(2,fmat(:,:,1),fmat(:,:,2));
lab_image=cat(2,lab_image,fmat(:,:,3));

lab_image=transpose(lab_image);

xbar=mean(lab_image,2);
mean_deducted=lab_image-xbar;
% L=transpose(mean_deducted)*mean_deducted;
L=mean_deducted*transpose(mean_deducted);
[eigvals,eigvecs]=eig(L);
[diagonal,indices]=sort(diag(eigvals),'descend');
eigvecs=eigvecs(:,indices);
V_hat=eigvecs(:,1:3);
eigspace=transpose(V_hat)*mean_deducted;
transformedspace=transpose(eigspace);

%% clustering
clusters=20;
idx=kmeans(transformedspace,clusters);
animg=zeros([(m-4)*(n-4),1]);
atoms=[];

for iter=1:clusters
    indices=find(idx==iter);
    animg(indices,1)=iter;
    atom=mean(transformedspace(indices,:),1);
    atoms = cat(1,atoms,atom);
end
txanimg=transpose(animg);
newimg=reshape(txanimg,m-4,n-4);
% figure,imshow(mat2gray(newimg)),colorbar;

cov=[];
% for j=1:clusters
%     for iter=1:clusters
%         cov(j,iter)=var((atoms(j,:)-atoms(iter,:)).^2);
%     end
% end
cov=atoms*transpose(atoms);
Pij=[];
for i=1:clusters
    for j=1:clusters
        if i==j
            continue
        else
            g=exp((-0.5)*(atoms(i,:).^2)/cov(i,j));
            Pij(i,j)=g(1)*g(2)*g(3);
        end
    end
end

%% phase 4
% Pij=normalize(Pij);
beta=1-Pij;

for i=1:clusters
    for j=1:clusters
        if i==j
            continue
        else
            beta(i,j)=1-Pij(i,j);
        end
    end
end
beta=normalize(beta);
% beta=double(1)-double(Pij);

for i=1:clusters
    for j=1:clusters
        if i==j
            beta(i,j)=0;
        end
    end
end

%Spatial gaussian mask
spatch=zeros((m-4),(n-4));
% sigma_spat=m/3;
sigma_spat=100;
row=1;
ci=(m-4)/2;
cj=(n-4)/2;
%set up the spatial gaussian mask
for i=1:m-4
    col=1;
    for j=1:n-4
        pow=sqrt((i-ci)*(i-ci)+(j-cj)*(j-cj));
        pow=pow*pow;
%         spatch(i,j)=-pow/(sigma_spat*sigma_spat);
        spatch(i,j)=exp(-pow/(2*sigma_spat*sigma_spat))/(sigma_spat*sqrt(2*pi));
        col=col+1;
    end
    row=row+1;
end
center_dist=[];
 for iter=1:clusters
    indices=find(idx==iter);
    center_dist(iter)=exp( (-1/length(indices))*sum(spatch(indices)) );
 end

 alpha=zeros(clusters,1);
for iter=1:clusters
    g=exp((-0.5)*(atoms(iter,:).^2)./sum(cov(iter,:)));
    Pix(iter)=g(1)*g(2)*g(3);
%     indices=find(idx==iter);
%     Pix(iter)=length(indices)/((m-4)*(n-4));
    for j=1:clusters
        if iter==j
            continue
        else
            alpha(iter)=alpha(iter)+beta(iter,j)*Pix(iter)*center_dist(iter);
        end
    end
end

saliency_map=zeros(1,(m-4)*(n-4));

 for iter=1:clusters
    indices=find(idx==iter);
    saliency_map(indices)=alpha(iter);
 end
 saliency_map=reshape(saliency_map,m-4,n-4);

figure,imshow(mat2gray(saliency_map)),colorbar;

%% manual thresholding
threshold_map=zeros(size(saliency_map));indices=find(saliency_map==alpha(4));
% threshold_map(indices)=spatch(indices);
threshold_map(indices)=1;
% threshold_map=threshold_map.*spatch(indices);
figure,imshow(mat2gray(threshold_map)),colorbar;

%% Adaptive thresholding

mu = mean(alpha);
sd = sqrt(var(alpha));
ada_thresh= mu +sd;
threshold_map=saliency_map;
indices=find(saliency_map>ada_thresh);
threshold_map(indices)=1;
indices=find(saliency_map<ada_thresh);
threshold_map(indices)=0;

figure,imshow(mat2gray(threshold_map)),colorbar;

%% grabcut

m1=m-4;
n1=n-4;
roi=boolean(zeros(m1,n1));
roi(m1/4:3*m1/4,n1/4:3*n1/4)=true;
indices=find(spatch~=0);
region=boolean(zeros(m1,n1));
region(indices)=true;
new=boolean(threshold_map);

salient_img=grabcut(res_im,threshold_map,new);

figure,imshow(mat2gray(salient_img)),colorbar;

%% feature matrix
function feature_matrix=computeFeatures(im,m,n,window_size)
diff=(window_size-1)/2;
feature_matrix=[];
x1=1;
y1=1;
x2=1;
y2=1;

f=waitbar(0,"Please wait...");
% Ignoring boundary conditions for now.
for j=3:n-2
    msg='Processing...';
    f = waitbar(j/(n-2),f,msg);
    for i=3:m-2
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
    end
end
close(f);
end
