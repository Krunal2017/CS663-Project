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
    % l1(2:end,:)=sort(l1(2:end,:));

    l2=im2col(padded_im(:,:,2),[5 5]);
    l2([1 13],:) = l2([13 1],:);
    layer2=cat(1,l2(2:6,:),l2(22:25,:));
    layer2=cat(1,layer2,l2([7,11,12,16,17,21],:));
    layer1=[];
    layer1=cat(1,layer1,l2([8,9,10,13,14,15,18,19,20],:));
    l2(2:end,:)=cat(1,sort(layer1),sort(layer2));
    % l2(2:end,:)=sort(l2(2:end,:));

    l3=im2col(padded_im(:,:,3),[5 5]);
    l3([1 13],:) = l3([13 1],:);
    layer2=cat(1,l3(2:6,:),l3(22:25,:));
    layer2=cat(1,layer2,l3([7,11,12,16,17,21],:));
    layer1=[];
    layer1=cat(1,layer1,l3([8,9,10,13,14,15,18,19,20],:));
    l3(2:end,:)=cat(1,sort(layer1),sort(layer2));
    % l3(2:end,:)=sort(l3(2:end,:));

    lab_image=[];
    lab_image=cat(1,l1,l2);
    lab_image=double(cat(1,lab_image,l3));

%     fmat=zeros((m-4)*(n-4),25,p);
% %     f = waitbar(0,"Please Wait...");
% 
%     for iter=1:p
% %         msg=strcat('Processing Channel-',num2str(iter));
% %         f = waitbar(iter/p,f,msg);
%         fmat(:,:,iter)=computeFeatures(im(:,:,iter),m,n,window_size);
%     end
% %     close(f);
% 
%     % using myPCA method
% 
%     lab_image=[];
%     lab_image=cat(2,fmat(:,:,1),fmat(:,:,2));
%     lab_image=cat(2,lab_image,fmat(:,:,3));
% 
%     lab_image=transpose(lab_image);

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

    %figure,imshow(mat2gray(saliency_map)),colorbar;
    %imwrite(mat2gray(saliency_map),'output2.png');
    result = mat2gray(saliency_map);

    
    %% manual thresholding
%     threshold_map=zeros(size(saliency_map));indices=find(saliency_map>0.80);
%     threshold_map(indices)=1;
%     threshold_map=padarray(threshold_map,[2 2],0,'both');
% %     figure,imshow(mat2gray(threshold_map)),colorbar;

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

    %% feature matrix
    function feature_matrix=computeFeatures(im,m,n,window_size)
    diff=(window_size-1)/2;
    feature_matrix=[];
    x1=1;
    y1=1;
    x2=1;
    y2=1;

    %f=waitbar(0,"Please wait...");
    % Ignoring boundary conditions for now.
    for j=3:n-2
        %msg='Processing...';
        %f = waitbar(j/(n-2),f,msg);
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
    %close(f);
    end
end