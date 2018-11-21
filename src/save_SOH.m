%% SAVE SOH FOR DATABASE
tic;

window_size = 8;
keyword = 'CoffeeMug';
database_dir = '../SampleImages/';

% Process the database
dir_name = strcat(database_dir,keyword);
D = dir(strcat(dir_name,'/*.jpg')); % check dir command, in matlab documentation
%N=floor(length(D)*0.8);
N=floor(length(D));

%ADA_THRES_MASKS=[];
%SALIENCY_MAPS=[];
SALIENCY_HISTOGRAMS=[];
f = waitbar(0,"Please Wait...");

for i=1:N
    msg=strcat('Computing SOH ',num2str(i),'/',num2str(N));
    f = waitbar(i/N,f,msg);
     filename = strcat(strcat(dir_name,'/'),D(i).name);
     X=double(imread(filename));
     [im,mask1] = textureDistinctMap(X);
%     if size(im,1)<800
%         a=800-size(im,1);
%     end
%     if size(im,2)<1028
%         b=1028-size(im,2);
%     end
%     padded_im=padarray(im,[a/2,b/2],0,'both');
%     padded_mask=padarray(mask1,[a/2,b/2],0,'both');
%     SALIENCY_MAPS(:,:,i)=padded_im;
%     ADA_THRES_MASKS(:,:,i)=padded_mask;
     [image, Ix, Iy, x, y] = featureExtraction(double(X),mask1);
     cx=x;
     cy=y;
%      figure,imshow(mat2gray(image)),title('Salient points'), hold on, scatter(y,x,'filled','r');

     h = soh(Ix, Iy, x, y, window_size);
     SALIENCY_HISTOGRAMS(:,:,i)=h;
end
close(f);
soh_file = strcat(strcat('../SOH_save/',keyword),'_200_mhec_sal_hists.mat');
%save('../SOH_save/train_harris_sal_maps.mat','SALIENCY_MAPS');
%save('../SOH_save/train_harris_sal_masks.mat','ADA_THRES_MASKS');
save(soh_file,'SALIENCY_HISTOGRAMS');


% TEST_ADA_THRES_MASKS=[];
% TEST_SALIENCY_MAPS=[];
% TEST_SALIENCY_HISTOGRAMS=[];
% iter=1;
% for i=N+1:length(D)% for each file in the directory(1 and 2 are '.' and '..')
%      filename = strcat('../../THUR15000/CoffeeMug/Src/',D(i).name);
%      X=double(imread(filename));
%      [im,mask1] = textureDistinctMap(X);
%      if size(im,1)<1000
%          a=1000-size(im,1);
%      end
%      if size(im,2)<1000
%          b=1000-size(im,2);
%      end
%      padded_im=padarray(im,[a/2,b/2],0,'both');
%      padded_mask=padarray(mask1,[a/2,b/2],0,'both');
%      TEST_SALIENCY_MAPS(:,:,iter)=padded_im;
%      TEST_ADA_THRES_MASKS(:,:,iter)=padded_mask;
%      [image, Ix, Iy, x, y] = featureExtraction(double(X),mask1);
%      cx=x;
%      cy=y;
% %      figure,imshow(mat2gray(image)),title('Salient points'), hold on, scatter(y,x,'filled','r');
% 
%      h = soh(Ix, Iy, x, y, window_size);
%      TEST_SALIENCY_HISTOGRAMS(:,:,iter)=h;
% end
% save('../SOH_save/test_harris_sal_maps.mat','TEST_SALIENCY_MAPS');
% save('../SOH_save/test_harris_sal_masks.mat','TEST_ADA_THRES_MASKS');
% save('../SOH_save/test_harris_sal_hists.mat','TEST_SALIENCY_HISTOGRAMS');
toc;