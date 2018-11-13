%% SBIR USING MHEC AND SOH
tic;

window_size = 8;

%Query image
q_im = imread('../SampleImages/CoffeMug/6.jpg');
im=q_im;
mask = imread('../SampleImages/CoffeMug/6.png');
mask=mask./mask;
% [im, mask] = textureDistinctMap(q_im);
% figure, imshow(im);
% figure, imshow(mask);
[q_image, Ix, Iy, x, y] = featureExtraction(double(im),mask);
% figure,imshow(mat2gray(q_image)),title('Query Image Salient points'), hold on, scatter(y,x,'filled','r');
q_h = soh(Ix, Iy, x, y, window_size);
%Process the database
D = dir('../SampleImages/CoffeMug/WithMask/*.jpg'); % check dir command, in matlab documentation
score = zeros(length(D)-2);
D1 = dir('../SampleImages/CoffeMug/WithMask/*.png'); % check dir command, in matlab documentation

for i=3:length(D)% for each file in the directory(1 and 2 are '.' and '..')
     filename = strcat('../SampleImages/CoffeMug/WithMask/',D(i).name);
     X=imread(filename);
     filename = strcat('../SampleImages/CoffeMug/WithMask/',D1(i).name);
     mask1=imread(filename);
     mask1=mask1./mask1;
     im=X;
     %figure,imshow(X)
     
%      [im,mask] = textureDistinctMap(X);
%      figure, imshow(im);
%      figure, imshow(mask);

     [image, Ix, Iy, x, y] = featureExtraction(double(im),mask1);
%      figure,imshow(mat2gray(image)),title('Salient points'), hold on, scatter(y,x,'filled','r');
     h = soh(Ix, Iy, x, y, window_size);
     s = similarity_score(q_h, h);
     score(i-2)=s;
%      disp('Score: ');
%      disp(num2str(s));
     if s>0
         figure,imshow(mat2gray(image)),title('Found Image');
         disp('Score: ');
         disp(num2str(s));
     end
end
score = sum(score,2);
toc;