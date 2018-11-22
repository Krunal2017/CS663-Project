function [result,threshold_map] = textureDistinctMap(im)
    im=padarray(im,[2 2],0,'both');
    [m n p]=size(im);
    m1=m-4;
    n1=n-4;
    res_im=im(3:m-2,3:n-2,1:3);
    window_size=5;
    padded_im=padarray(im,[0,0],0,'both');

    l1=im2col(padded_im(:,:,1),[5 5]);
    l1([1 13],:) = l1([13 1],:);
    layer2=cat(1,l1(2:6,:),l1(22:25,:));
    layer2=cat(1,layer2,l1([7,11,12,16,17,21],:));
    layer1=[];
    layer1=cat(1,layer1,l1([8,9,10,13,14,15,18,19,20],:));
    l1(2:end,:)=cat(1,sort(layer1),sort(layer2));

    l2=im2col(padded_im(:,:,2),[5 5]);
    l2([1 13],:) = l2([13 1],:);
    layer2=cat(1,l2(2:6,:),l2(22:25,:));
    layer2=cat(1,layer2,l2([7,11,12,16,17,21],:));
    layer1=[];
    layer1=cat(1,layer1,l2([8,9,10,13,14,15,18,19,20],:));
    l2(2:end,:)=cat(1,sort(layer1),sort(layer2));

    l3=im2col(padded_im(:,:,3),[5 5]);
    l3([1 13],:) = l3([13 1],:);
    layer2=cat(1,l3(2:6,:),l3(22:25,:));
    layer2=cat(1,layer2,l3([7,11,12,16,17,21],:));
    layer1=[];
    layer1=cat(1,layer1,l3([8,9,10,13,14,15,18,19,20],:));
    l3(2:end,:)=cat(1,sort(layer1),sort(layer2));

    lab_image=[];
    lab_image=cat(1,l1,l2);
    lab_image=double(cat(1,lab_image,l3));

    xbar=mean(lab_image,2);
    mean_deducted=lab_image-xbar;
    L=mean_deducted*transpose(mean_deducted);
    [eigvals,eigvecs]=eig(L);
    [diagonal,indices]=sort(diag(eigvals),'descend');
    eigvecs=eigvecs(:,indices);
    V_hat=eigvecs(:,1:3);
    eigspace=transpose(V_hat)*mean_deducted;
    transformedspace=transpose(eigspace);

    %% clustering
    clusters=20;
    idx=kmeans(transformedspace,clusters,'start','uniform');
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

    cov=[];
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

    for i=1:clusters
        for j=1:clusters
            if i==j
                beta(i,j)=0;
            end
        end
    end

    %Spatial gaussian mask
    spatch=zeros((m-4),(n-4));
    sigma_spat=20;
    row=1;
    ci=(m-4)/2;
    cj=(n-4)/2;
    %set up the spatial gaussian mask
    for i=1:m-4
        col=1;
        for j=1:n-4
            pow=sqrt((i-ci)*(i-ci)+(j-cj)*(j-cj));
            pow=pow*pow;
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

    result = mat2gray(saliency_map);

%% Adaptive thresholding
    mu=mean(mean(result));
    sd=sqrt(var(var(result)));
    ada_thresh=mu+sd;
    threshold_map=zeros(size(result));indices=find(result>ada_thresh);
    threshold_map(indices)=1;
%% Grabcut Segmentation of thresholded mask
    [m1,n1,p1]=size(res_im);
    roi=logical(zeros(m1,n1));
    roi(1*m1/4:3*m1/4,1*n1/4:3*n1/4)=true; 
    L = superpixels(res_im,200);
    thres_mask = grabcut(res_im,L,roi);
end