%% SBIR USING MHEC AND SOH
tic;

window_size = 8;

% %Query image
% q_im = imread('../SampleImages/CoffeMug/6.jpg');
% [im, mask] = textureDistinctMap(q_im);
% % figure(1), imshow(mat2gray(im));
% % figure(2), imshow(mat2gray(mask));
% 
% [q_image, Ix, Iy, x, y] = featureExtraction(double(q_im),mask);
% % figure,imshow(q_image),title('Query Image Salient points'), hold on, scatter(y,x,'filled','r');
% 
% q_h = soh(Ix, Iy, x, y, window_size);

% Process the database
D = dir('../../THUR15000/CoffeeMug/Src/*.jpg'); % check dir command, in matlab documentation
score = zeros(length(D),1);
N=floor(length(D)*0.8);

ADA_THRES_MASKS=[];
SALIENCY_MAPS=[];
SALIENCY_HISTOGRAMS=[];
for i=1:N% for each file in the directory(1 and 2 are '.' and '..')
     filename = strcat('../../THUR15000/CoffeeMug/Src/',D(i).name);
     X=double(imread(filename));
     [im,mask1] = textureDistinctMap(X);
     if size(im,1)<800
         a=800-size(im,1);
     end
     if size(im,2)<1028
         b=1028-size(im,2);
     end
     padded_im=padarray(im,[a/2,b/2],0,'both');
     padded_mask=padarray(mask1,[a/2,b/2],0,'both');
     SALIENCY_MAPS(:,:,i)=padded_im;
     ADA_THRES_MASKS(:,:,i)=padded_mask;
     [image, Ix, Iy, x, y] = featureExtraction(double(X),mask1);
     cx=x;
     cy=y;
%      figure,imshow(mat2gray(image)),title('Salient points'), hold on, scatter(y,x,'filled','r');

     h = soh(Ix, Iy, x, y, window_size);
     SALIENCY_HISTOGRAMS(:,:,i)=h;
%      norm_thres=0.5;    % can be 0.5 for squared diff or 0.9 of normalized diff
%      [s] = similarity_score(q_h, h, norm_thres);
%      score(i-2)=s;
% %      if s<0.5
% %          figure,imshow(mat2gray(image)),title('Salient points'), hold on, scatter(cy,cx,'filled','r');
% %          figure,imshow(mat2gray(image)),title('Found Image');
%          disp('Score: ');
%          disp(num2str(s));
% %      end
end
save('train_harris_sal_maps.mat','SALIENCY_MAPS');
save('train_harris_sal_masks.mat','ADA_THRES_MASKS');
save('train_harris_sal_hists.mat','SALIENCY_HISTOGRAMS');


TEST_ADA_THRES_MASKS=[];
TEST_SALIENCY_MAPS=[];
TEST_SALIENCY_HISTOGRAMS=[];
iter=1;
for i=N+1:length(D)% for each file in the directory(1 and 2 are '.' and '..')
     filename = strcat('../../THUR15000/CoffeeMug/Src/',D(i).name);
     X=double(imread(filename));
     [im,mask1] = textureDistinctMap(X);
     if size(im,1)<1000
         a=1000-size(im,1);
     end
     if size(im,2)<1000
         b=1000-size(im,2);
     end
     padded_im=padarray(im,[a/2,b/2],0,'both');
     padded_mask=padarray(mask1,[a/2,b/2],0,'both');
     TEST_SALIENCY_MAPS(:,:,iter)=padded_im;
     TEST_ADA_THRES_MASKS(:,:,iter)=padded_mask;
     [image, Ix, Iy, x, y] = featureExtraction(double(X),mask1);
     cx=x;
     cy=y;
%      figure,imshow(mat2gray(image)),title('Salient points'), hold on, scatter(y,x,'filled','r');

     h = soh(Ix, Iy, x, y, window_size);
     TEST_SALIENCY_HISTOGRAMS(:,:,iter)=h;
%      norm_thres=0.5;    % can be 0.5 for squared diff or 0.9 of normalized diff
%      [s] = similarity_score(q_h, h, norm_thres);
%      score(i-2)=s;
% %      if s<0.5
% %          figure,imshow(mat2gray(image)),title('Salient points'), hold on, scatter(cy,cx,'filled','r');
% %          figure,imshow(mat2gray(image)),title('Found Image');
%          disp('Score: ');
%          disp(num2str(s));
% %      end
end
save('test_harris_sal_maps.mat','TEST_SALIENCY_MAPS');
save('test_harris_sal_masks.mat','TEST_ADA_THRES_MASKS');
save('test_harris_sal_hists.mat','TEST_SALIENCY_HISTOGRAMS');
% score = sum(score,2);
toc;